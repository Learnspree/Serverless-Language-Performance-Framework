
import os
import json
import boto3
import datetime
import math

from decimal import *
from enum import Enum
from getruntime import decimalencoder
from getruntime import queryfilter

from boto3.dynamodb.conditions import Key, Attr
from botocore.exceptions import ClientError, ParamValidationError

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

def getSummaryStats(event, context):
    inputRuntime = '{}'.format(event['pathParameters']['runtimeId'])
    
    queryFilterExpression = queryfilter.getDynamoFilterExpression(event['queryStringParameters'])
    return getComputedValues(inputRuntime, queryFilterExpression)

def getComputedValues(inputRuntime, queryFilterExpression):
    table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

    # fetch metrics from the database
    print('Language Runtime Input: ', inputRuntime)

    try:
        if (queryFilterExpression is None):
            allMatchingRows = table.query(
                TableName=os.environ['DYNAMODB_TABLE'],
                KeyConditionExpression=Key('LanguageRuntime').eq('{}'.format(inputRuntime)),
                ProjectionExpression='LanguageRuntime, #duration, BilledDuration',
                ExpressionAttributeNames = { "#duration": "Duration" }
            )
        else:
            allMatchingRows = table.query(
                TableName=os.environ['DYNAMODB_TABLE'],
                KeyConditionExpression=Key('LanguageRuntime').eq('{}'.format(inputRuntime)),
                ProjectionExpression='LanguageRuntime, #duration, BilledDuration, ServerlessPlatformName',
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
                    "meanBilledDuration" : Decimal('-1.0'),
                    "maxExecution" : "",
                    "minExecution" : ""
                  } 

    try:
        if not allMatchingRows['Items']:
            print ("no records available for %s" % inputRuntime)
        else:
            totalDuration = Decimal('0.0')
            totalBilledDuration = Decimal('0.0')
            currentMaxDuration = Decimal('0.0')
            currentMinDuration = Decimal('1000000.0')
            maxExecutionRow = allMatchingRows['Items'][0]
            minExecutionRow = allMatchingRows['Items'][0]

            for row in allMatchingRows['Items']:
                rowDuration = row['Duration']
                totalDuration += rowDuration
                totalBilledDuration += row['BilledDuration']
                if rowDuration > currentMaxDuration:
                    currentMaxDuration = rowDuration
                    maxExecutionRow = row
                if rowDuration < currentMinDuration:
                    currentMinDuration = rowDuration
                    minExecutionRow = row

            returnValue = { 
                            "meanDuration" : totalDuration / allMatchingRows['Count'],
                            "meanBilledDuration" : int(math.ceil((totalBilledDuration / allMatchingRows['Count']) / Decimal(100.0))) * 100,
                            "maxExecution" : json.dumps(maxExecutionRow, cls=decimalencoder.DecimalEncoder),
                            "minExecution" : json.dumps(minExecutionRow, cls=decimalencoder.DecimalEncoder)
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