import decimal
import json
from decimal import *

def getCostForFunctionDuration(serverlessPlatform, billedDuration, memorySize):
    try:
        cost = 0.0

        gbSecondCost = calculateGBSecondCost(serverlessPlatform)
        invokeCost = calculateInvokeCost(serverlessPlatform)

        billedGigabits = memorySize / 1024
        billedSeconds = billedDuration / 1000
        gigabitSeconds = billedGigabits * billedSeconds
        gigabitSecondsCost = gigabitSeconds * gbSecondCost
        cost = invokeCost + gigabitSecondsCost

    except Exception as e:
        print("Generic error: %s" % e) 
        raise           

    return cost

def getCostPerMillionForBilledDuration(serverlessPlatform, billedDuration, memorySize):
    try:
        cost = getCostForFunctionDuration(serverlessPlatform, billedDuration, memorySize)
        cost = cost * 1000000

    except Exception as e:
        print("Generic error: %s" % e) 
        raise           

    return cost

def calculateGBSecondCost(serverlessPlatform):
    try:
        gbSecondCost = 0.0
        if (serverlessPlatform == "Azure Functions")
            gbSecondCost = os.environ['AZURE_FUNCTIONS_GBSECOND_COST']
        else:
            gbSecondCost = os.environ['AWS_LAMBDA_GBSECOND_COST']
    except Exception as e:
        print("Generic error: %s" % e) 
        raise           

    return gbSecondCost

def calculateInvokeCost(serverlessPlatform):
    try:
        invokeCost = 0.0
        if (serverlessPlatform == "Azure Functions")
            invokeCost = os.environ['AZURE_FUNCTIONS_INVOKE_COST']
        else:
            invokeCost = os.environ['AWS_LAMBDA_INVOKE_COST']
    except Exception as e:
        print("Generic error: %s" % e) 
        raise           

    return invokeCost   

# // FUTURE WORK - call out to the AWS Pricing API (see notes)
# // FUTURE WORK - create separate lambda to listen on SNS topic for price changes and store pricing in DynamoDB?

# 'use strict';

# const AWS = require('aws-sdk'); 
# const dynamoDb = new AWS.DynamoDB.DocumentClient();

# let emptyIfStringMetricNull = function (stringMetricValue) {
#   return (stringMetricValue == null) ? "" : stringMetricValue.S;
# };

# let zeroIfNumericMetricNull = function (numericMetricValue) {
#   return (numericMetricValue == null) ? "" : numericMetricValue.N;
# };

# module.exports.costmetrics = (event, context, callback) => {

#   // calculate and record cost for each updated record
#   console.log('Total Records in Cost Lambda: ' + event.Records.length);
#   event.Records.forEach(function(record) {

#     console.log('DynamoDB Record: %j', record.dynamodb);

#     if (record == null || 
#         record.dynamodb == null ||
#         record.dynamodb.NewImage == null)
#     {
#       // skip this record - there's no data
#       return;
#     }

#     // get values from Dynamo DB record
#     let requestIdValue = emptyIfStringMetricNull(record.dynamodb.NewImage.RequestId);
#     let billedDurationValue = zeroIfNumericMetricNull(record.dynamodb.NewImage.BilledDuration);
#     let memorySizeValue = zeroIfNumericMetricNull(record.dynamodb.NewImage.MemorySize);
#     let languageRuntimeValue = emptyIfStringMetricNull(record.dynamodb.NewImage.LanguageRuntime);

#     // get cost base values based on serverless framework in dynamo record
#     let serverlessFrameworkName = emptyIfStringMetricNull(record.dynamodb.NewImage.ServerlessPlatformName);
#     console.log(`Serverless Platform: ${serverlessFrameworkName}`);
#     let gbSecondCost = calculateGBSecondCost(serverlessFrameworkName);
#     let invokeCost = calculateInvokeCost(serverlessFrameworkName);

#     // calculate costs
#     let billedGigabits = memorySizeValue / 1024;
#     let billedSeconds = billedDurationValue / 1000;
#     let gigabitSeconds = billedGigabits * billedSeconds;  
#     let gigabitSecondsCost = gigabitSeconds * gbSecondCost;
#     let functionCostValue = invokeCost + gigabitSecondsCost;

#     console.log(`billedGigabits: ${billedGigabits}`);
#     console.log(`billedSeconds: ${billedSeconds}`);
#     console.log(`gigabitSeconds: ${gigabitSeconds}`);
#     console.log(`gigabitSecondsCost: ${gigabitSecondsCost}`);
#     console.log(`functionCostValue: ${functionCostValue}`);
    
#     // Create dynamo-db insert params from calculated data above
#     const params = {
#       TableName: process.env.DYNAMODB_COSTMETRICS_TABLE,
#       Item: {
#         RequestId : requestIdValue,
#         LanguageRuntime : languageRuntimeValue,
#         BilledDuration : billedDurationValue,
#         MemorySize : memorySizeValue,
#         FunctionCost : functionCostValue,
#         FunctionCostPerMillionRequests : functionCostValue * 1000000
#       }
#     };

#     // write the cost data to the database
#     dynamoDb.put(params, (error) => {
#       // log potential errors
#       if (error) {
#         console.error(error);
#       }
#     });
#   });

#   callback(null, "Cost Metrics Lambda Finished");
# };