from typing import List
import logging
import pandas as pd
import numpy as np
#import pyodbc  <-- not using but leaving just in case for whatever reason we need to write in
import json
import pickle
import pathlib
import os
import simplejson as jason
from threading import Lock

from azure.servicebus import ServiceBusClient, ServiceBusMessage
from .Inference import truck_matching_inference_v3_5 as tmv3

import azure.functions as func

log_level = os.getenv('LOG_LEVEL', 'WARNING')
logger = logging.getLogger(__name__)
logger.setLevel(logging._nameToLevel[log_level])
sh = logging.StreamHandler()
sh.setLevel(logging._nameToLevel[log_level])
logger.addHandler(sh)
logging.getLogger('azure.servicebus').setLevel(logging.WARNING)

# set feature flag
feature_flag = os.getenv('FEAT_FLAG', 'OFF')

# This is a required field in the message for Accelerate services
# It should be removed when possible or renamed to be more generic
accelerate_environment = os.getenv('ACCELERATE_ENVIRONMENT', 'unset')

# service bus setup
sb_client = ServiceBusClient.from_connection_string(os.environ['sbConnectionOut'])
sb_sender = sb_client.get_topic_sender(os.environ['sbTopicNameOut'])
sb_sender_dummy = sb_client.get_topic_sender(os.environ['sbTopicNameOutDummy'])

# Using the lock is for the service bus is necessary to avoid
# concurreny issues under high volume as it is not thread safe
_lock = Lock()

# setting up carrier / sonar data from CSVs in storage
logger.info('loading inference data begin')
c_lh = pd.read_csv(pathlib.Path(__file__).parent / "inference-data/carrier_lane_history/carrier_lane_history.csv", escapechar='\\')
cl = pd.read_csv(pathlib.Path(__file__).parent / "inference-data/carrier_locations/carrier_locations.csv", escapechar='\\')
c = pd.read_csv(pathlib.Path(__file__).parent / "inference-data/carrier_matching/carrier_matching.csv", escapechar='\\')
ci = pd.read_csv(pathlib.Path(__file__).parent / "inference-data/proper_city/proper_city.csv", escapechar='\\')
sd_1 = pd.read_csv(pathlib.Path(__file__).parent / "inference-data/sonar_data_1/sonar_data_1.csv", escapechar='\\')
sd_2 = pd.read_csv(pathlib.Path(__file__).parent / "inference-data/sonar_data_2/sonar_data_2.csv", escapechar='\\')
sd_3 = pd.read_csv(pathlib.Path(__file__).parent / "inference-data/sonar_data_3/sonar_data_3.csv", escapechar='\\')
t = pd.read_csv(pathlib.Path(__file__).parent / "inference-data/transcore_market_zone/transcore_market_zone.csv", escapechar='\\')
# below are 2 new DE files for DS to use

cz = pd.read_csv(pathlib.Path(__file__).parent / "inference-data/city_zips/city_zips.csv", escapechar='\\')
a_lh = pd.read_csv(pathlib.Path(__file__).parent / "inference-data/load_history/load_history.csv", escapechar='\\')
logger.info('loading inference data end')


# setting up models for more optimized usage
logger.info('loading models begin')
c2aPath = pathlib.Path(__file__).parent / 'Inference/clf_c2a.sav'
c2cPath = pathlib.Path(__file__).parent / 'Inference/clf_c2c.sav'

# Loading up the pickles 
clf_c2a = pickle.load(open(c2aPath, 'rb'))
clf_c2c = pickle.load(open(c2cPath, 'rb'))
logger.info('loading models end')


def main (msg: func.ServiceBusMessage, eventOut: func.Out[str]):

    try:

        # getting message and transform to json for processing etc
        m_json = msg.get_body().decode('utf-8')
        event_data_json = json.loads(m_json)
        correlation_id = event_data_json['CorrelationId']
        #logger.debug(m_json)
        logging.info('inputs processed')

        # separating out just the match list that needs to be graded
        input_matches = event_data_json['MatchesToGradingList']
        #logger.info(input_matches)

        # transforming to dataframe and correcting a couple of fields pre-modelling
        input_matches_df = pd.DataFrame(input_matches)
        input_matches_df[['TruckDestinationCityText','TruckDestinationStateText']] = input_matches_df[['TruckDestinationCityText','TruckDestinationStateText']].astype(str) 
        # input_matches_df['DestinationDeadHeadMiles'] = pd.array(input_matches_df.DestinationDeadHeadMiles, dtype=pd.Int64Dtype())

        # merging in staged data with dataframe of matches being sent in to the model
        logging.info('merging data')
        to_be_graded = tmv3.merge_data(input_matches_df,c,c_lh,ci,sd_1,sd_2,sd_3,t,cz) # <-- add in city zip file
        to_be_graded_audit = to_be_graded.copy()
        #logger.debug(to_be_graded.to_json(orient='records'))
        logger.info('data merged')

        logger.info("begin DS modeling")
        # this now returns a data frame instead of a dict
        predictions = tmv3.process(to_be_graded,cl,a_lh,clf_c2a,clf_c2c)
        logger.info('end DS modeling')
        logger.debug(predictions)

        # post-processing starts here to convert fields to proper data types
        predictions[['DestinationDeadHeadMiles','CarrierRepUserId']] = predictions[['DestinationDeadHeadMiles','CarrierRepUserId']].replace(np.nan, -1)
        predictions[['DestinationDeadHeadMiles','CarrierRepUserId']] = predictions[['DestinationDeadHeadMiles','CarrierRepUserId']].astype(int)

        # just straight up iterate over all the values and check for -1 and set to None
        grade_output = [{k: v for k, v in x.items()} for x in predictions.to_dict('records')]
        for fix in grade_output:
            for k,v in fix.items():
                if k in ('DestinationDeadHeadMiles', 'CarrierRepUserId', 'FirstLoadDate'): 
                    if v == -1:
                        fix[k] = None
                    elif v == 'NaT':
                        fix[k] = None
                    else:
                        pass

        output = {
            'MatchesToGradingList': grade_output
        }

        logger.debug(output)

        # send the audit log for data science analysis
        to_be_graded_audit[['MatchCreatedOn']] = to_be_graded_audit[['MatchCreatedOn']].astype(str)
        audit_output = {"correlationId": correlation_id, "environment": accelerate_environment, "inputToModel": to_be_graded_audit.to_dict('records'), "output": output}
        logger.debug(jason.dumps(audit_output, ignore_nan=True, use_decimal=True))
        eventOut.set(jason.dumps(audit_output, ignore_nan=True, use_decimal=True))

        # send service bus message
        sb_message = format_service_bus_message(jason.dumps(output, ignore_nan=True, use_decimal=True), correlation_id)
        if feature_flag == "ON":
            with _lock:
                sb_sender.send_messages(sb_message)
        else:
            with _lock:
                sb_sender_dummy.send_messages(sb_message)

        logger.info(f"output message sent to service bus for corelationId {correlation_id}")

    except Exception as err:
        error = {
            'error': err,
            'inputMessage': msg,
            # 'inputToModel': to_be_graded_audit.to_dict('records')
        }

        logger.error(error)


def format_service_bus_message(body, correlation_id):
    return ServiceBusMessage(
        body,
        correlation_id = correlation_id,
        content_type = 'application/json',
        application_properties = {
            'MessageTypeName': 'NewGradingMatchesEventMessageList',
            'MessageSender': 'MatchingAlgorithmFunction',
            'AccelerateEnvironment': accelerate_environment,
            'MessageType': 'Matching.Domain.Messages.NewGradingMatchesEventMessageList, Matching.Domain, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null'
            },
        subject = 'update-matches-grading-topic',
        label = 'update-matches-grading-topic'
    )

