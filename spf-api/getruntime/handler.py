
import os
import json

from getruntime import decimalencoder
import boto3
dynamodb = boto3.resource('dynamodb')

def getMaximum(event, context):
    table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

    # fetch metrics from the database
    print('Language Runtime: ', event['pathParameters']['runtimeId'])

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

    # create a response
    response = {
        "statusCode": 200,
        #"body": json.dumps(result['Item'],
                           # cls=decimalencoder.DecimalEncoder)
        "body": "completed"
    }

    return response