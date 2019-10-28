
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

    targetPlatform = None
    if event['queryStringParameters'] is not None and event['queryStringParameters']['platform'] is not None:
        targetPlatform = '{}'.format(event['queryStringParameters']['platform'])
    
    queryFilterExpression = getDynamoFilterExpression(event['queryStringParameters'])
    return getComputedValue(inputRuntime, targetPlatform, QueryType.MEAN)

def getDynamoFilterExpression(eventQueryParams):
    if eventQueryParams is None:
        return None 
    
    filterExp = None
    filterExp = combineFilterExpression(filterExp, eventQueryParams['state'], 'State')
    filterExp = combineFilterExpression(filterExp, eventQueryParams['platform'], 'ServerlessPlatformName')
    
    return filterExp

def combineFilterExpression(filterExp, queryParamValue, dynamoTableColumnName):
    if queryParamValue is None:
        return filterExp

    if filterExp is None:
        filterExp = Key(dynamoTableColumnName).eq(queryParamValue) 
    else:
        filterExp = filterExp & Key(dynamoTableColumnName).eq(queryParamValue)

    return filterExp

def getComputedValue(inputRuntime, targetPlatform, queryType):
    table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

    # fetch metrics from the database
    print('Language Runtime Input: ', inputRuntime)
    print('RequestType: ', queryType)
    print('TargetPlatform: ', targetPlatform)

    try:
        filterExp = '' if (targetPlatform is None) else Key('ServerlessPlatformName').eq(targetPlatform)

        if (targetPlatform is None):
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
                FilterExpression=filterExp
            )
    except ParamValidationError as e:
        print("Parameter validation error: %s" % e)        
    except ClientError as e:
        print("Unexpected error: %s" % e)
    except Exception as e:
        print("Generic error: %s" % e)
        
    print(allMatchingRows)
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