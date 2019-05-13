
import os
import json

from getruntime import decimalencoder
import boto3
from boto3.dynamodb.conditions import Key, Attr
from botocore.exceptions import ClientError, ParamValidationError

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

def getMaximum(event, context):
    table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

    # fetch metrics from the database
    inputRuntime = '{}'.format(event['pathParameters']['runtimeId'])
    print('Language Runtime Input: ', inputRuntime)
    
    try:
        result = table.query(
            TableName=os.environ['DYNAMODB_TABLE'],
            KeyConditionExpression=Key('LanguageRuntime').eq('{}'.format(inputRuntime)),
            ProjectionExpression='LanguageRuntime, #duration',
            ExpressionAttributeNames = { "#duration": "Duration" }
        )
        # result = table.scan()
    except ParamValidationError as e:
        print("Parameter validation error: %s" % e)        
    except ClientError as e:
        print("Unexpected error: %s" % e)
    except Exception as e:
        print("Generic error: %s" % e)
        
    returnValue = ""
    maxDuration = -1
    print(result)
    for i in result['Items']:
        duration = i['Duration']
        if duration > maxDuration:
            maxDuration = duration
            returnValue = json.dumps(i) 
    
    # create a response
    response = {
        "statusCode": 200,
        "body": returnValue
    }

    return response