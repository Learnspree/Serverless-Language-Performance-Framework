
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

class QueryType(Enum):
    MEAN = 1

def getMeanDuration(event, context):
    inputRuntime = '{}'.format(event['pathParameters']['runtimeId'])
    
    queryFilterExpression = queryfilter.getDynamoFilterExpression(event['queryStringParameters'])
    return getComputedValue(inputRuntime, queryFilterExpression, QueryType.MEAN)

def getComputedValue(inputRuntime, queryFilterExpression, queryType):
    table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

    # fetch metrics from the database
    print('Language Runtime Input: ', inputRuntime)
    print('RequestType: ', queryType)

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
            
            meanBilledDuration = int(math.ceil((totalBilledDuration / allMatchingRows['Count']) / Decimal(100.0))) * 100
            returnValue = { 
                            "meanDuration" : totalDuration / allMatchingRows['Count'],
                            "meanBilledDuration" : meanBilledDuration,
                            "count" : allMatchingRows['Count'],
                            # TODO - set input memory into cost call to be the query filter memorySize or default to 128 if not there
                            # Note the SPF website always sends a memory size. Other clients can display a caveat on costs that it was defaulted to 
                            # 128 because multiple memory sizes were involved. In future, could calculate average memory and round up to next memory level.
                            "cost" : calculatecost.getCostForFunctionDuration("AWS Lambda", Decimal(meanBilledDuration), Decimal('128')),
                            "costPerMillion" : calculatecost.getCostPerMillionForBilledDuration("AWS Lambda", Decimal(meanBilledDuration), Decimal('128'))
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