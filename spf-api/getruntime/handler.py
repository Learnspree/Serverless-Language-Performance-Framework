
import os
import json

from getruntime import decimalencoder
import boto3
from boto3.dynamodb.conditions import Key, Attr
from botocore.exceptions import ClientError, ParamValidationError

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

def getMaximum(event, context):
    table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])
    #table = dynamodb.Table('TestServerless')

    # fetch metrics from the database
    inputRuntime = '{}'.format(event['pathParameters']['runtimeId'])
    print('Language Runtime: ', inputRuntime)
    

    # TODO - change to a query as get_item requires full key including ID ?
    # START RequestId: 05a3e6e4-c39d-4064-a798-9df5b5a47377 Version: $LATEST
    # Language Runtime:  java8
    #     raise error_class(parsed_response, operation_name) _make_api_calliong the GetItem operation: The provided key element does not match the schema
    # END RequestId: 05a3e6e4-c39d-4064-a798-9df5b5a47377
    # REPORT RequestId: 05a3e6e4-c39d-4064-a798-9df5b5a47377	Duration: 287.08 ms	Billed Duration: 300 ms 	Memory Size: 128 MB	Max Memory Used: 67 MB	
    # result = table.get_item(
    #     Key={
    #         'LanguageRuntime': event['pathParameters']['runtimeId']
    #     }
    # )
    
    try:
        # result = table.query(
        #     KeyConditionExpression=Key('LanguageRuntime').eq('{}'.format(inputRuntime)),
        #     ProjectionExpression='LanguageRuntime'
        # )
        result = table.scan()
    except ParamValidationError as e:
        print("Parameter validation error: %s" % e)        
    except ClientError as e:
        print("Unexpected error: %s" % e)
    except Exception as e:
        print("Generic error: %s" % e)
        
    
    # result = dynamodb.query(
    #     TableName='TestServerless',
    #     KeyConditionExpression=Key('LanguageRuntime').eq('{}'.format(inputRuntime)) 
    # )

    print('Language Runtime: ', inputRuntime)

    returnValue = ""
    print(result)
    for i in result['Items']:
        newValue = i['LanguageRuntime'], ":" #, i['RequestId']
        print(newValue)
        returnValue += newValue

    # create a response
    response = {
        "statusCode": 200,
        "body": returnValue
        #"body": json.dumps(result['Item'],
                          # cls=decimalencoder.DecimalEncoder)
        # "body": "completed"
    }

    return response