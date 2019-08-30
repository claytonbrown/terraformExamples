import logging
import requests
import json

# if you open the initializer feature, please implement the initializer function, as below:
# def initializer(context):
#   logger = logging.getLogger()
#   logger.info('initializing')

def handler(event, context):
  logger = logging.getLogger()
  #logger.info('hello world')
  evt = json.loads(event)

  # Extract event details (ECS-specific?)
  level = evt.get("level")  
  name = evt.get("name")
  user = evt.get("userId")
  region = evt.get("regionId")
  content = evt.get("content")

  # URL of the Slack webhook
  end_url = 'https://hooks.slack.com/services/your_actual_hook'
  headers = {'Content-type': 'application/json'}

  # Formulate event message  
  msg = "[{}] Event '{}' was triggered by user ID '{}' in region '{}'\n".format(level, name, user, region)

  # Convert the contents of the event notification into friendlier, non-JSON format
  for key in content:
    msg += "\n{}: {}".format(key, content.get(key))
  msg += '\n' 

  # Send message to slack
  payload = {'text': msg}
  logger.info("level : "+level+"\nname : "+name)
  r = requests.post(end_url,headers=headers, data=json.dumps(payload))
  
  return 'ok'