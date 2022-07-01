from typing import List, final
import logging
import pandas as pd
import numpy as np
import json
import pickle
import pathlib
import os
from datetime import datetime, timedelta, date
from threading import Lock

from Inference.cost_prediction_inference import ControlFunc
from .Inference import cost_prediction_inference as cpi

import azure.functions as func

log_level = os.getenv('LOG_LEVEL', 'WARNING')
logger = logging.getLogger(__name__)
logger.setLevel(logging._nameToLevel[log_level])
sh = logging.StreamHandler()
sh.setLevel(logging._nameToLevel[log_level])
logger.addHandler(sh)

accelerate_environment = os.getenv('ENVIRONMENT', 'unset')
inference_folder = pathlib.Path(__file__).parent.joinpath("inference-data")

# load inference data
logger.info('loading inference data begin')
a2m = pd.read_csv(pathlib.Path(__file__).parent / "inference-data/airport_to_market/airport_to_market.csv",
                  escapechar='\\')
cpsd = pd.read_csv(pathlib.Path(__file__).parent / "inference-data/cp_sonar_data/cp_sonar_data.csv", escapechar='\\')
lcpm = pd.read_csv(pathlib.Path(__file__).parent / "inference-data/load_cost_per_mile/load_cost_per_mile.csv",
                   escapechar='\\')
cd = pd.read_csv(pathlib.Path(__file__).parent / "inference-data/city_data/loc_city.csv", escapechar='\\')
md = pd.read_csv(pathlib.Path(__file__).parent / "inference-data/market_data/market_data.csv", escapechar='\\')

fuel_rate = pd.read_csv(inference_folder.joinpath("cp_fuelrate_data", "cp_fuelrate_data.csv"), escapechar='\\')
fuel_schedule = pd.read_csv(inference_folder.joinpath("cp_arrive_standard_van_fuel_surcharge_schedule",
                                                      "cp_arrive_standard_van_fuel_surcharge_schedule.csv"),
                            escapechar='\\')
cd = cd.where(pd.notnull(cd), None)

# remove duplicates due to a bug that created duplicate records
# TODO remove this one the bug has been fixed
lcpm = lcpm.drop_duplicates()

# logger.info(cd.head())
lcpm = lcpm.where(pd.notnull(lcpm), None)
a2m = a2m.where(pd.notnull(a2m), None)
cpsd = cpsd.where(pd.notnull(cpsd), None)
md = md.where(pd.notnull(md), None)

lcpm[['PICKUPDAY']] = lcpm[['PICKUPDAY']].astype('datetime64[ns]')
logger.info('loading inference data end')
logger.info(lcpm.dtypes)

# setting up models for more optimized usage
logger.info('loading models begin')
cpmPath = pathlib.Path(__file__).parent / 'inference-data/cp_model.pkl'

# Loading up the pickles 
cpModel = pickle.load(open(cpmPath, 'rb'))
logger.info('loading models end')


def main(req: func.HttpRequest, eventOut: func.Out[str]) -> func.HttpResponse:
    common_headers = {
        'Content-Type': 'application/json'
    }

    modelOutput = {}
    audit_output = {}
    correlation_id = 'notset'

    try:

        # parse and validate input
        input_json = req.get_body().decode('utf8').replace("'", '"')
        input_dict = json.loads(input_json)
        logger.info(input_json)
        # moving correlation id to be pulled from body of request
        # correlation_id = req.headers['correlationId'] if 'correlationId' in req.headers else correlation_id
        correlation_id = input_dict['CorrelationId']
        # load_date = input_dict.pop('LoadDate') # <---- commenting now that they want to use date
        common_headers['CorrelationId'] = correlation_id
        use_stub = True if 'stub' in req.params and req.params['stub'].lower() == 'true'.lower() else False
        logger.debug(f"using stub {use_stub}")
        logger.debug({"correlationId": correlation_id, "input": input_dict})

        # logging.info('starting to validate')
        if not validate_input(input_dict):
            logger.error(
                {'correlationId': correlation_id, 'error': 'Bad Request', 'input': input_dict, 'stub': use_stub})

            audit_output = {
                'correlationId': correlation_id,
                'input': input_dict,
                'output': 'Error bad request',
                'stub': use_stub
            }
            eventOut.set(json.dumps(audit_output))
            return func.HttpResponse(
                json.dumps({'correlationId': correlation_id, 'error': 'Bad request', 'input': input_dict}),
                status_code=400, headers=common_headers)
        logging.info('finished validating')
        if use_stub:
            finalForm = get_stub()
        else:
            # logging.info('moving to DS model')
            logging.info(input_dict)
            pd.set_option("display.max_rows", None, "display.max_columns", None)
            input_df = []
            input_df = pd.DataFrame.from_records([input_dict])
            input_df[['DestinationLocationKey', 'LoadTypeCode', 'OriginLocationKey', 'CorrelationId']] = input_df[
                ['DestinationLocationKey', 'LoadTypeCode', 'OriginLocationKey', 'CorrelationId']].astype(str)
            # removed old unnecessary code
            # logging.info(input_df)
            logging.info('now calling inference code')
            modelOutput = ControlFunc(input_df, cd, a2m, cpsd, lcpm, cpModel, md, fuel_rate, fuel_schedule)
            logging.info(modelOutput)
            # finalForm = modelOutput.to_dict()
            almostFinalForm = [{k: v for k, v in x.items()} for x in modelOutput.to_dict('records')]
            logging.info(almostFinalForm)
            # finalForm = {}
            finalForm = almostFinalForm[0]
            finalForm['CorrelationId'] = correlation_id
            # finalForm['ConfidenceLevel']="Very High" <-- commenting out artificial confidence level
            logging.info(finalForm)
            logging.info(type(finalForm))
            # finalForm = json.dumps(finalForm)
            logging.info(json.dumps(finalForm))

        audit_output = {'correlationId': correlation_id, 'input': input_dict, 'output': finalForm, 'stub': use_stub}
        eventOut.set(json.dumps(audit_output))
        return func.HttpResponse(json.dumps(finalForm), status_code=200, headers=common_headers)

    except Exception as err:
        logger.error({'correlationId': correlation_id, 'error': err, 'input': input_dict, 'stub': use_stub})
        msg = ''
        if hasattr(err, 'message'):
            msg = err.message
        else:
            msg = err
        eventOut.set(json.dumps({'correlationId': correlation_id, 'error': err, 'input': input_dict, 'stub': use_stub}))
        return func.HttpResponse(
            json.dumps({'correlationId': correlation_id, 'error': 'Unexpected error', 'error_detail': str(msg)}),
            status_code=500, headers=common_headers)


def validate_input(input):
    """
    sample input:
    {
        "DestinationLocationKey": "CITY_10937",
        "LoadTypeCode": "V",
        "LoadTypeId": 1,
        "Miles": 792.013,
        "OriginLocationKey": "CITY_11132",
        "CorrelationId": "5907da51-ad93-4e1b-a05c-59b9fdfe5c21",
        "LoadDate":"2022-12-28T16:22:03.03Z" <----- add this later
    }
    """

    # Map your validation functions to the keys
    validations = {}

    if isinstance(input["Miles"], int):
        logger.info("orig and dest are the same")
        validations = {
            "DestinationLocationKey": lambda x: isinstance(x, str),
            "LoadTypeCode": lambda x: isinstance(x, str),
            "LoadTypeId": lambda x: isinstance(x, int) and 1 <= x,
            "Miles": lambda x: isinstance(x, int) and 1 <= x,
            "OriginLocationKey": lambda x: isinstance(x, str),
            "LoadDate": lambda x: isinstance(x, str),
            "CorrelationId": lambda x: isinstance(x, str)
        }
    else:
        validations = {
            "DestinationLocationKey": lambda x: isinstance(x, str),
            "LoadTypeCode": lambda x: isinstance(x, str),
            "LoadTypeId": lambda x: isinstance(x, int) and 1 <= x,
            "Miles": lambda x: isinstance(x, float) and 1 <= x,
            "OriginLocationKey": lambda x: isinstance(x, str),
            "LoadDate": lambda x: isinstance(x, str),
            "CorrelationId": lambda x: isinstance(x, str)
        }
    # set empty list to check validated datatypes
    results = []
    for k, v in input.items():
        results.append(validations.get(k, lambda x: False)(v))

    # check types and if any fail then fail the validation
    for i in results:
        if i == False:
            logger.error(" (╯°□°）╯︵ ┻━┻ ")
            return False
        else:
            logger.info(" (☞ﾟヮﾟ)☞ ")

    return True


def get_stub():
    return {
        'LinehaulTotal': 1872.4164,
        'LinehaulPerMile': 1.1761,
        'FSCTotal': 382.08,
        'FSCPerMile': 0.24,
        'CorrelationId': "5907da51-ad93-4e1b-a05c-59b9fdfe5c21",
        'ConfidenceLevel': "Very High"
    }
