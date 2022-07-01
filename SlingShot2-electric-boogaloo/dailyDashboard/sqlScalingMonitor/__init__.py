from typing import List
import json
import datetime
import requests
import os
import pathlib
import logging

import azure.functions as func

# something wrong with the message? bail tf out!  (っ▀¯▀)つ
def bail(msg):
    logging.error(msg)
    exit(1)

# set newrelic info
new_relic_event_name = 'AutoScalingReport' # removing check not needed if os.getenv('NEW_RELIC_EVENT_NAME') == None else os.getenv('NEW_RELIC_EVENT_NAME')
new_relic_key = os.getenv('NEW_RELIC_KEY')

# bail bail bail! (っ▀¯▀)つ (っ▀¯▀)つ (っ▀¯▀)つ
if new_relic_key == None:
    bail('Unable to determine New Relic api key')

def main(events: List[func.EventHubEvent]):
    for event in events:
        body = event.get_body().decode('utf-8')
        sql_event = json.loads(body)
        #logging.info(sql_event)
        nr_event = process(sql_event)
        publish_event(nr_event)

# (☞ﾟヮﾟ)☞ SHAMELESSLY ripping this from Slingshot v1 and modifying, also no env stuff, also no if else checks 
# basically just converting what gets sent in to something a bit more NewRelic friendly 
def process(release_event):
    #logging.info(release_event)
    custom_event = {}
  
    custom_event['eventType'] = new_relic_event_name
    records = release_event["records"][0]

    try:
        custom_event['appName'] = records["properties"]["RunbookName"]
        custom_event['resultType'] = records["resultType"]
        custom_event['JobId'] = records["properties"]["JobId"]

        # weird gross datetime stuff DON'T YOU JUDGE ME  ಥ﹏ಥ 
        off_set = datetime.datetime.utcnow() - datetime.datetime.now()
        ts = records['time']
        dt = ts.split('.')[0]
        date_time_obj = datetime.datetime.strptime(dt, '%Y-%m-%dT%H:%M:%S') - off_set
        custom_event['azureTs'] = int(date_time_obj.timestamp())
    
        
    except Exception as err:
        logging.error(err)
        raise

    logging.info(custom_event)

    return custom_event

    

def publish_event(event):
    url = "https://insights-collector.newrelic.com/v1/accounts/2801856/events"
    payload = json.dumps(event)
    headers = {
    'X-Insert-Key': new_relic_key,
    'Content-Type': 'application/json'
    }
    response = requests.request("POST", url, headers=headers, data = payload)
    logging.info(response.text)