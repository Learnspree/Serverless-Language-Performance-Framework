
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
        # todo - use a local secondary index to enable query sort by duration. see https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LSI.html#LSI.Using
        result = table.query(
            TableName=os.environ['DYNAMODB_TABLE'],
            IndexName='duration-index',
            KeyConditionExpression=Key('LanguageRuntime').eq('{}'.format(inputRuntime)),
            ProjectionExpression='LanguageRuntime, #duration',
            ExpressionAttributeNames = { "#duration": "Duration" },
            ScanIndexForward=True # sort descending
            ##FilterExpression=Attr('Platform').begins_with("AWS") - note FilterExpression good for future querying for certain CSPs etc.
        )
    except ParamValidationError as e:
        print("Parameter validation error: %s" % e)        
    except ClientError as e:
        print("Unexpected error: %s" % e)
    except Exception as e:
        print("Generic error: %s" % e)
        
    returnValue = ""
    maxDuration = -1

    try:
        if not result['Items']:
            print ("no records available for %s" % inputRuntime)
        else:
            maxItem = result['Items'][0]
            print(maxItem)
            jsonString = json.dumps(maxItem, cls=decimalencoder.DecimalEncoder)
            print(jsonString)
            returnValue = jsonString
    except Exception as e:
        print("Generic error: %s" % e)  
    
    # create a response
    response = {
        "statusCode": 200,
        "body": returnValue
    }

    return response