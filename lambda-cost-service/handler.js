// FUTURE WORK - call out to the AWS Pricing API (see notes)
// FUTURE WORK - create separate lambda to listen on SNS topic for price changes and store pricing in DynamoDB?

'use strict';

const AWS = require('aws-sdk'); 
const dynamoDb = new AWS.DynamoDB.DocumentClient();

let emptyIfStringMetricNull = function (stringMetricValue) {
  return (stringMetricValue == null) ? "" : stringMetricValue.S;
};

let zeroIfNumericMetricNull = function (numericMetricValue) {
  return (numericMetricValue == null) ? "" : numericMetricValue.N;
};

let calculateGBSecondCost = function (serverlessFrameworkName) {
  // default to AWS Lambda values
  let gbSecondCost = 0;
  switch(serverlessFrameworkName) {
    case "Azure Functions":
        gbSecondCost = parseFloat(process.env.AZURE_FUNCTIONS_GBSECOND_COST);
        break;
    default:
        gbSecondCost = parseFloat(process.env.AWS_LAMBDA_GBSECOND_COST);
  }
  return gbSecondCost;
}

let calculateInvokeCost = function (serverlessFrameworkName) {
  // default to AWS Lambda values
  let invokeCost = 0;
  switch(serverlessFrameworkName) {
    case "Azure Functions":
        invokeCost = parseFloat(process.env.AZURE_FUNCTIONS_INVOKE_COST);
        break;
    default:
        invokeCost = parseFloat(process.env.AWS_LAMBDA_INVOKE_COST);
  }
  return invokeCost;
}

module.exports.costmetrics = (event, context, callback) => {

  // calculate and record cost for each updated record
  console.log('Total Records in Cost Lambda: ' + event.Records.length);
  event.Records.forEach(function(record) {

    console.log('DynamoDB Record: %j', record.dynamodb);

    if (record == null || 
        record.dynamodb == null ||
        record.dynamodb.NewImage == null)
    {
      // skip this record - there's no data
      return;
    }

    // get values from Dynamo DB record
    let requestIdValue = emptyIfStringMetricNull(record.dynamodb.NewImage.RequestId);
    let billedDurationValue = zeroIfNumericMetricNull(record.dynamodb.NewImage.BilledDuration);
    let memorySizeValue = zeroIfNumericMetricNull(record.dynamodb.NewImage.MemorySize);
    let languageRuntimeValue = emptyIfStringMetricNull(record.dynamodb.NewImage.LanguageRuntime);

    // get cost base values based on serverless framework in dynamo record
    let serverlessFrameworkName = emptyIfStringMetricNull(record.dynamodb.NewImage.ServerlessPlatformName);
    console.log(`Serverless Platform: ${serverlessFrameworkName}`);
    let gbSecondCost = calculateGBSecondCost(serverlessFrameworkName);
    let invokeCost = calculateInvokeCost(serverlessFrameworkName);

    // calculate costs
    let billedGigabits = memorySizeValue / 1024;
    let billedSeconds = billedDurationValue / 1000;
    let gigabitSeconds = billedGigabits * billedSeconds;  
    let gigabitSecondsCost = gigabitSeconds * gbSecondCost;
    let functionCostValue = invokeCost + gigabitSecondsCost;

    console.log(`billedGigabits: ${billedGigabits}`);
    console.log(`billedSeconds: ${billedSeconds}`);
    console.log(`gigabitSeconds: ${gigabitSeconds}`);
    console.log(`gigabitSecondsCost: ${gigabitSecondsCost}`);
    console.log(`functionCostValue: ${functionCostValue}`);
    
    // Create dynamo-db insert params from calculated data above
    const params = {
      TableName: process.env.DYNAMODB_COSTMETRICS_TABLE,
      Item: {
        RequestId : requestIdValue,
        LanguageRuntime : languageRuntimeValue,
        BilledDuration : billedDurationValue,
        MemorySize : memorySizeValue,
        FunctionCost : functionCostValue,
        FunctionCostPerMillionRequests : functionCostValue * 1000000
      }
    };

    // write the cost data to the database
    dynamoDb.put(params, (error) => {
      // log potential errors
      if (error) {
        console.error(error);
      }
    });
  });

  callback(null, "Cost Metrics Lambda Finished");
};
