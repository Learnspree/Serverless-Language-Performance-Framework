from boto3 import client as boto3_client
from datetime import datetime
import json

lambda_client = boto3_client('lambda')

def burst_invoker(event, context):

    print('Event Count: ', event['invokeCount'])
    print('Event Target: ', event['targetFunctionName'])

    # putting in a hard limit for safety
    if event['invokeCount'] > 100:
        return

    for x in range(event['invokeCount']):
        invoke_response = lambda_client.invoke(FunctionName=event['targetFunctionName'],
                                            InvocationType='Event')
        print(invoke_response)