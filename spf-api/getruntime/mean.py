
import os
import json
import boto3

from decimal import *
from enum import Enum
from getruntime import decimalencoder

from boto3.dynamodb.conditions import Key, Attr
from botocore.exceptions import ClientError, ParamValidationError

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

class QueryType(Enum):
    MEAN = 1

def getMeanDuration(event, context):
    inputRuntime = '{}'.format(event['pathParameters']['runtimeId'])
    return getComputedValue(inputRuntime, QueryType.MEAN)

def getComputedValue(inputRuntime, queryType):
    table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

    # fetch metrics from the database
    print('Language Runtime Input: ', inputRuntime)
    print('RequestType: ', queryType)
    
    try:
        allMatchingRows = table.query(
            TableName=os.environ['DYNAMODB_TABLE'],
            IndexName='duration-index',
            KeyConditionExpression=Key('LanguageRuntime').eq('{}'.format(inputRuntime)),
            ProjectionExpression='LanguageRuntime, #duration, BilledDuration',
            ExpressionAttributeNames = { "#duration": "Duration" } #, "#timestamp": "Timestamp" }
            ##FilterExpression=Attr('Platform').begins_with("AWS") - note FilterExpression good for future querying for certain CSPs etc.
        )
    except ParamValidationError as e:
        print("Parameter validation error: %s" % e)        
    except ClientError as e:
        print("Unexpected error: %s" % e)
    except Exception as e:
        print("Generic error: %s" % e)
        
    returnValue = { 
                    "meanDuration" : Decimal('-1.0'),
                    "meanBilledDuration" : Decimal('-1.0')
                  } 
    totalDuration = Decimal('0.0')
    totalBilledDuration = Decimal('0.0')

    try:
        if not allMatchingRows['Items']:
            print ("no records available for %s" % inputRuntime)
        else:
            for row in allMatchingRows['Items']:
                totalDuration += row['Duration']
                totalBilledDuration += row['BilledDuration']
            returnValue = { 
                            "meanDuration" : totalDuration / allMatchingRows['Count'],
                            "meanBilledDuration" : totalBilledDuration / allMatchingRows['Count']
                          } 
    except Exception as e:
        print("Generic error: %s" % e)  
    
    # create a response
    response = {
        "statusCode": 200,
        "body": json.dumps(returnValue, cls=decimalencoder.DecimalEncoder)
    }

    return response