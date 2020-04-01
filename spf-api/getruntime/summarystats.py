
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
from botocore.config import Config
from botocore.exceptions import ClientError, ParamValidationError

# TODO - parameterize timeouts/retries so we can increase for prod. Also look at timeout in serverless.yml
config = Config(connect_timeout=1, read_timeout=1, retries={'max_attempts': 1})
dynamodb = boto3.resource('dynamodb', region_name='us-east-1', config=config)

# setup pre-canned application error response
errorResponse = {
    "statusCode": 500,
    "headers": {
        "Access-Control-Allow-Origin": "*", # Required for CORS support to work
        "Access-Control-Allow-Credentials": "false", # Required for cookies, authorization headers with HTTPS
    },
    "body": { "message" : "An error occurred" }
}

# TotalDuration (and InitDuration which is part of TotalDuration) were added after initial data gathering commenced.
# Handle both scenarios here - if TotalDuration is present, use it.
# If not - use 'Duration' which will always be there 
def getRowDuration(row):
    if row.get('TotalDuration'):
        return row['TotalDuration']
    else:
        return row['Duration']

def getRowExecutionDuration(row):
    return row['Duration']

def getSummaryStats(event, context):

    inputRuntime = '{}'.format(event['pathParameters']['runtimeId'])
    queryFilterExpression = queryfilter.getDynamoFilterExpression(event['queryStringParameters'])
    table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

    print('Language Runtime Input: ', inputRuntime)

    # set default return value
    returnValue = { 
                "meanDuration" : Decimal('-1.0'),
                "meanBilledDuration" : Decimal('-1.0'),
                "maxExecution" : None,
                "minExecution" : None,
                "count" : 0,
                "cost" : 0,
                "costPerMillion" : 0
                } 

    # fetch metrics from the database
    # initialize parameters set here for potential loops for paging
    totalDuration = Decimal('0.0')
    totalDurationForBilling = Decimal('0.0')
    currentMaxDuration = Decimal('0.0')
    currentMinDuration = Decimal('1000000.0')
    maxExecutionRow = None
    minExecutionRow = None

    moreRecordsExist = True
    lastEvaluatedKey = None
    totalRowCount = 0

    # loop for potential paging
    while moreRecordsExist:

        try:
            query_params = { 
                'TableName': os.environ['DYNAMODB_TABLE'],
                'KeyConditionExpression': Key('LanguageRuntime').eq('{}'.format(inputRuntime)),
                'ProjectionExpression': 'LanguageRuntime, #duration, InitDuration, TotalDuration, BilledDuration, ServerlessPlatformName',
                'ExpressionAttributeNames': { "#duration": "Duration" }
            }
            if queryFilterExpression:
                query_params['FilterExpression'] = queryFilterExpression
            if lastEvaluatedKey:
                query_params['ExclusiveStartKey'] = lastEvaluatedKey

            # params ready - do the query
            allMatchingRows = table.query(**query_params)

        except ParamValidationError as e:
            print("Parameter validation error: %s" % e)  
            return errorResponse      
        except ClientError as e:
            print("Unexpected error (e.g. ProvisionedThroughputExceededException): %s" % e)
            return errorResponse
        except Exception as e:
            print("Generic error: %s" % e)
            return errorResponse

        try:
            if not allMatchingRows['Items']:
                f'no more records available for {inputRuntime}. Total Count: {totalRowCount}'
                moreRecordsExist = False
                lastEvaluatedKey = None
            else:
                totalRowCount += allMatchingRows['Count']
                moreRecordsExist = ('LastEvaluatedKey' in allMatchingRows)
                if moreRecordsExist:
                    lastEvaluatedKey = allMatchingRows['LastEvaluatedKey']

                # process results of this "page" of the query
                for row in allMatchingRows['Items']:
                    rowDuration = getRowDuration(row)
                    totalDuration += rowDuration
                    totalDurationForBilling += getRowExecutionDuration(row)
                    if rowDuration > currentMaxDuration:
                        currentMaxDuration = rowDuration
                        maxExecutionRow = row
                    if rowDuration < currentMinDuration:
                        currentMinDuration = rowDuration
                        minExecutionRow = row
        except Exception as e:
            print("Error retrieving data from DynamoDB Table: %s" % e)  
            return errorResponse

    # End of query loop - now total up and return the overall result 
    try:
        meanBilledDuration = int(math.ceil((totalDurationForBilling / totalRowCount) / Decimal(100.0))) * 100
        memoryAllocationForCostCalc = queryfilter.getMemoryFromQueryString(event['queryStringParameters'])
        serverlessPlatformName = queryfilter.getPlatformFromQueryString(event['queryStringParameters'])

        returnValue = { 
                        "meanDuration" : totalDuration / totalRowCount,
                        "meanBilledDuration" : meanBilledDuration,
                        "maxExecution" : maxExecutionRow,
                        "minExecution" : minExecutionRow,
                        "count" : totalRowCount,
                        "cost" : calculatecost.getCostForFunctionDuration(serverlessPlatformName, Decimal(meanBilledDuration), memoryAllocationForCostCalc),
                        "costPerMillion" : calculatecost.getCostPerMillionForBilledDuration(serverlessPlatformName, Decimal(meanBilledDuration), memoryAllocationForCostCalc)
                        } 
    except Exception as e:
        print("Error calculating totals: %s" % e)  
        return errorResponse
    
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