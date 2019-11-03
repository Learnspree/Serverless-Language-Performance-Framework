
import os
import json
import boto3

from enum import Enum
from getruntime import decimalencoder
from getruntime import queryfilter

from boto3.dynamodb.conditions import Key, Attr
from botocore.exceptions import ClientError, ParamValidationError

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

class QueryType(Enum):
    MIN = 1
    MAX = 2

def getMinimum(event, context):
    return getMinMax(event, QueryType.MIN)

def getMaximum(event, context):
    return getMinMax(event, QueryType.MAX)

def getMinMax(event, queryType):
    table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])
    inputRuntime = '{}'.format(event['pathParameters']['runtimeId'])
    queryFilterExpression = queryfilter.getDynamoFilterExpression(event['queryStringParameters'])

    # fetch metrics from the database
    print('Language Runtime Input: ', inputRuntime)
    print('RequestType: ', queryType)
    
    try:
        if (queryFilterExpression is None):
            result = table.query(
                TableName=os.environ['DYNAMODB_TABLE'],
                IndexName='duration-index',
                KeyConditionExpression=Key('LanguageRuntime').eq('{}'.format(inputRuntime)),
                ProjectionExpression='LanguageRuntime, #duration, BilledDuration, FunctionName, FunctionVersion, #timestamp, MemorySize, MemoryUsed, ServerlessPlatformName',
                ExpressionAttributeNames = { "#duration": "Duration", "#timestamp": "Timestamp" },
                ScanIndexForward=(queryType == QueryType.MIN) # sort descending ('false' for maximum) or ascending ('true' for minimum)
            )
        else:
            result = table.query(
                TableName=os.environ['DYNAMODB_TABLE'],
                IndexName='duration-index',
                KeyConditionExpression=Key('LanguageRuntime').eq('{}'.format(inputRuntime)),
                ProjectionExpression='LanguageRuntime, #duration, BilledDuration, FunctionName, FunctionVersion, #timestamp, MemorySize, MemoryUsed, ServerlessPlatformName',
                ExpressionAttributeNames = { "#duration": "Duration", "#timestamp": "Timestamp" },
                ScanIndexForward=(queryType == QueryType.MIN), 
                FilterExpression=queryFilterExpression
            )
    except ParamValidationError as e:
        print("Parameter validation error: %s" % e)        
    except ClientError as e:
        print("Unexpected error: %s" % e)
    except Exception as e:
        print("Generic error: %s" % e)
        
    returnValue = ""

    try:
        if not result['Items']:
            print ("no records available for %s" % inputRuntime)
        else:
            selectedItem = result['Items'][0]
            print(selectedItem)
            jsonString = json.dumps(selectedItem, cls=decimalencoder.DecimalEncoder)
            returnValue = jsonString
    except Exception as e:
        print("Generic error: %s" % e)  
    
    # create a response
    response = {
        "statusCode": 200,
        "body": returnValue
    }

    return response