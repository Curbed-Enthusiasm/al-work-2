import logging
import json
import datetime
import requests
import os
import pathlib
import azure.functions as func

# something wrong with the message? bail tf out!  (っ▀¯▀)つ
def bail(msg):
    logging.error(msg)
    exit(1)

# set newrelic info
new_relic_event_name = 'DailyOpsReport' if os.getenv('NEW_RELIC_EVENT_NAME') == None else os.getenv('NEW_RELIC_EVENT_NAME')
new_relic_key = os.getenv('NEW_RELIC_KEY')

# bail bail bail! (っ▀¯▀)つ (っ▀¯▀)つ (っ▀¯▀)つ
if new_relic_key == None:
    bail('Unable to determine New Relic api key')

def main(msg: func.ServiceBusMessage):
    body = msg.get_body().decode('utf-8')
    logging.info(body)
    nr_event = json.loads(body)
    event =  process(nr_event)
    #logging.info(event)
    publish_event(event)

# (☞ﾟヮﾟ)☞ SHAMELESSLY ripping this from Slingshot v1 and modifying, also no env stuff, also no if else checks 
# basically just converting what gets sent in to something a bit more NewRelic friendly 
def process(release_event):
    #logging.info(release_event)
    custom_event = {}
  
    custom_event['eventType'] = new_relic_event_name

    try:
        appName = ''
        
        for event in release_event:
            
            custom_event['appName'] = release_event["logicAppName"]
            custom_event['succeeded'] = release_event["success"]

            off_set = datetime.datetime.utcnow() - datetime.datetime.now()
            dt = release_event['timestamp']
            date_time_obj = datetime.datetime.strptime(dt, '%Y-%m-%d %H:%M:%S') - off_set
        
            # adding custom events in
            custom_event['azureTs'] = int(date_time_obj.timestamp())
    except Exception as err:
        logging.error(err)
        raise

    #logging.info(custom_event)

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