from cgitb import text
import logging
import os
import json
import re
from urllib import parse as urlparse
import base64
import requests
import time
import datetime
from datetime import timedelta

import azure.functions as func

SLACK_URL = 'https://slack.com/api/conversations.history'
PARAMS = {'channel': 'CPEUYRF1Q'}
TOKEN = 'Bearer '+ os.environ['SLACK_BOT_TOKEN']
logging.info(TOKEN)
# slack_client = WebClient(token=os.getenv['SLACK_BOT_TOKEN'])

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')


    msg_map = dict(urlparse.parse_qsl(req.get_body().decode('utf-8')))  # data comes b64 and also urlencoded name=value& pairs
    msg_text = msg_map.get("text")
    #slack_response_url = msg_map.get("response_url")
    slack_response_url = 'https://slack.com/api/chat.postMessage'
    #logging.info(msg_map)


    logging.info('sending request...NOW')

    alert_counts = get_history(msg_text)
    response_block = blockify(msg_text,alert_counts)
    payload = json.dumps({'channel': 'CPEUYRF1Q', 'blocks': response_block})

    logging.info(payload)

    #slack_post = requests.post(slack_response_url, headers={'Authorization': TOKEN, "Content-type": "application/json"}, data=payload)
    #logging.info(slack_post.text)

    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    if name:
        return func.HttpResponse(f"Hello, {name}. This HTTP triggered function executed successfully.{payload}")
    else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully.",
             status_code=200
        )

def get_history(timeEntry):
    '''
    this function takes the text passed in from the slash command
    then uses it to set the 'oldest' param for the GET request in to slack
    then returns the conversation history for parsing
    '''
    slack_api_url = 'https://slack.com/api/conversations.history'
    logging.info('calling get_history')

    today = datetime.datetime.now()
    oldest = today - timedelta(days=int(timeEntry))
    unix_ts = datetime.datetime.timestamp(oldest)*1000
    #PARAMS['oldest']=unix_ts
    slack_api_url = slack_api_url + '?channel=CPEUYRF1Q&oldest=' + str(unix_ts) + '&inclusive=true'
    logging.info(unix_ts)
    convo_history = requests.get(slack_api_url, headers={'Authorization': TOKEN })
    slack_hist_text = json.loads(convo_history.text)
    slack_msgs = slack_hist_text.get('messages')
    #logging.info('history retrieved')

    # setting up regex for pulling info from the slack message history
    dlq_keywords = [r'Dead', r'Letter', r'Queue']
    dlq_regex = '|'.join(dlq_keywords)
    app_svc_keywords = [r'Resource', r'Metric']
    app_svc_regex = '|'.join(app_svc_keywords)
    
    dlq_count = 0
    app_svc_count = 0

    # regex and parsing some of the data into simple constructs to send back to slack
    for message in slack_msgs:
        individual_msg = message.get('text')
        dlqs = re.findall(dlq_regex, individual_msg, re.I)
        apps = re.findall(app_svc_regex, individual_msg, re.I)
        if dlqs:
            dlq_count += 1
        elif apps:
            app_svc_count += 1

    logging.info(slack_msgs)
    logging.info('dlq count = ' + str(dlq_count))
    logging.info('app svc count = ' + str(app_svc_count))

    incident_count = [dlq_count, app_svc_count]
    return incident_count

def blockify(timeEntry, countList):
    '''
    slack block response generation

    '''
    #block = '[{"type": "section","text": {"type": "mrkdwn","text": "*These are the past occurrences from N days:*"}},{"type": "section","text": {"type": "mrkdwn","text": "- test 1\n- test 2\n- test 3"}},{"type": "section","text": {"type": "mrkdwn","text": "_misc test_"}}]'

    block = [
                {
                        "type": "section",
                        "text": {
                                "type": "mrkdwn",
                                "text": "*These are the occurrences from the past " + str(timeEntry) + " days:*"
                        }
                },
                {
                        "type": "section",
                        "text": {
                                "type": "mrkdwn",
                                "text": "Dead Letter Queues\n-" + str(countList[0]) + "\nApp Service Alerts\n-" + str(countList[1])
                        }
                },
                {
                        "type": "section",
                        "text": {
                                "type": "mrkdwn",
                                "text": "_misc test_"
                        }
                }
        ]
    #channel_msg = "Dead Letter Queues\n-" + str(countList[0]) + "\nApp Service Alerts\n-" + str(countList[1])
    #final_block = json.dumps(block)
    logging.info(block)
    return block


#     curl -H "Content-type: application/json" \
# --data '{"channel":"CPEUYRF1Q","text":"test"}' \
# -H "Authorization: Bearer xoxb-" \
# -X POST https://slack.com/api/chat.postMessage

# curl -H "Content-type: application/json" \
# --data '{"channel":"CPEUYRF1Q","blocks":[
#                 {
#                         "type": "section",
#                         "text": {
#                                 "type": "mrkdwn",
#                                 "text": "*These are the past occurrences from N days:*"
#                         }
#                 },
#                 {
#                         "type": "section",
#                         "text": {
#                                 "type": "mrkdwn",
#                                 "text": "- test 1\n- test 2\n- test 3"
#                         }
#                 },
#                 {
#                         "type": "section",
#                         "text": {
#                                 "type": "mrkdwn",
#                                 "text": "_misc test_"
#                         }
#                 }
#         ]
# }' \
# -H "Authorization: Bearer xoxb-rest-of-token-here" \
# -X POST https://slack.com/api/chat.postMessage