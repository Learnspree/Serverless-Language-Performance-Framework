
import os
import json
import boto3
import datetime

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
    
    queryFilterExpression = getDynamoFilterExpression(event['queryStringParameters'])
    return getComputedValue(inputRuntime, queryFilterExpression, QueryType.MEAN)

def getDynamoFilterExpression(eventQueryParams):
    if eventQueryParams is None:
        return None 
    
    filterExp = None
    filterExp = combineFilterExpressionFromQueryString(filterExp, eventQueryParams, 'state', 'State')
    filterExp = combineFilterExpressionFromQueryString(filterExp, eventQueryParams, 'platform', 'ServerlessPlatformName')
    filterExp = combineFilterExpressionFromQueryString(filterExp, eventQueryParams, 'memory', 'MemorySize')
    filterExp = combineFilterExpressionFromQueryString(filterExp, eventQueryParams, 'functionname', 'FunctionName')
    filterExp = combineFilterExpressionFromQueryString(filterExp, eventQueryParams, 'region', 'Region')
    filterExp = combineFilterExpressionFromQueryString(filterExp, eventQueryParams, 'zone', 'Zone')

    # datetime filters for start/end date are in UNIX epoch timestamp format as in nodejs Date.now() method
    # e.g. 1518951734319
    filterExp = combineFilterExpressionFromQueryString(filterExp, eventQueryParams, 'startdate', 'Timestamp')
    filterExp = combineFilterExpressionFromQueryString(filterExp, eventQueryParams, 'enddate', 'Timestamp')

    return filterExp

def combineFilterExpressionFromQueryString(filterExp, queryParams, queryParamKey, dynamoTableColumnName):
    if queryParamKey not in queryParams:
        return filterExp

    # convert numeric fields from string to float for dynamodb query on Number (N)
    queryParamValue = queryParams[queryParamKey]
    if queryParamValue.isnumeric():
        queryParamValue = Decimal(queryParamValue)

    # default to "equals" comparison
    newFilterExp = Key(dynamoTableColumnName).eq(queryParamValue)

    # use <= or >= if looking at date ranges
    if queryParamKey.find("startdate") > -1:
        newFilterExp = Key(dynamoTableColumnName).gte(queryParamValue)
    elif queryParamKey.find("enddate") > -1:
        newFilterExp = Key(dynamoTableColumnName).lte(queryParamValue)
            
    if filterExp is None:
        filterExp = Key(dynamoTableColumnName).eq(queryParamValue) 
    else:
        filterExp = filterExp & Key(dynamoTableColumnName).eq(queryParamValue)

    return filterExp

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