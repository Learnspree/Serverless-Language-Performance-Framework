
import os
import json
import boto3
import datetime
import math

from decimal import *
from enum import Enum
from getruntime import decimalencoder
from getruntime import queryfilter
from getruntime import calculatecost

from boto3.dynamodb.conditions import Key, Attr
from botocore.exceptions import ClientError, ParamValidationError

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

# TotalDuration (and InitDuration which is part of TotalDuration) were added after initial data gathering commenced.
# Handle both scenarios here - if TotalDuration is present, use it.
# If not - use 'Duration' which will always be there 
def getRowDuration(row):
    if row.get('TotalDuration'):
        return row['TotalDuration']
    else:
        return row['Duration']

def getMeanDuration(event, context):
    queryFilterExpression = queryfilter.getDynamoFilterExpression(event['queryStringParameters'])
    inputRuntime = '{}'.format(event['pathParameters']['runtimeId'])

    table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

    # fetch metrics from the database
    print('Language Runtime Input: ', inputRuntime)

    try:
        if (queryFilterExpression is None):
            allMatchingRows = table.query(
                TableName=os.environ['DYNAMODB_TABLE'],
                KeyConditionExpression=Key('LanguageRuntime').eq('{}'.format(inputRuntime)),
                ProjectionExpression='LanguageRuntime, #duration, InitDuration, TotalDuration, BilledDuration, ServerlessPlatformName',
                ExpressionAttributeNames = { "#duration": "Duration" }
            )
        else:
            allMatchingRows = table.query(
                TableName=os.environ['DYNAMODB_TABLE'],
                KeyConditionExpression=Key('LanguageRuntime').eq('{}'.format(inputRuntime)),
                ProjectionExpression='LanguageRuntime, #duration, InitDuration, TotalDuration, BilledDuration, ServerlessPlatformName',
                ExpressionAttributeNames = { "#duration": "Duration" },
                FilterExpression = queryFilterExpression
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
                totalDuration += getRowDuration(row)
            
            meanDuration = totalDuration / allMatchingRows['Count']
            meanBilledDuration = int(math.ceil(meanDuration / Decimal(100.0))) * 100
            memoryAllocationForCostCalc = queryfilter.getMemoryFromQueryString(event['queryStringParameters'])
            serverlessPlatformName = queryfilter.getPlatformFromQueryString(event['queryStringParameters'])

            returnValue = { 
                            "meanDuration" : totalDuration / allMatchingRows['Count'],
                            "meanBilledDuration" : meanBilledDuration,
                            "count" : allMatchingRows['Count'],
                            "cost" : calculatecost.getCostForFunctionDuration(serverlessPlatformName, Decimal(meanBilledDuration), memoryAllocationForCostCalc),
                            "costPerMillion" : calculatecost.getCostPerMillionForBilledDuration(serverlessPlatformName, Decimal(meanBilledDuration), memoryAllocationForCostCalc)
                          } 
    except Exception as e:
        print("Generic error: %s" % e)  
    
    # create a response
    response = {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*", # Required for CORS support to work
            "Access-Control-Allow-Credentials": "false", # Required for cookies, authorization headers with HTTPS
        },
        "body": json.dumps(returnValue, cls=decimalencoder.DecimalEncoder)
    }

    return response