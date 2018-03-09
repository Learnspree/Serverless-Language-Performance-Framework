// FUTURE WORK - call out to the AWS Pricing API (see notes)
// FUTURE WORK - create separate lambda to listen on SNS topic for price changes and store pricing in DynamoDB?

'use strict';

const AWS = require('aws-sdk'); 
const dynamoDb = new AWS.DynamoDB.DocumentClient();

module.exports.costmetrics = (event, context, callback) => {

  let gbSecondCost = parseFloat(process.env.AWS_LAMBDA_GBSECOND_COST);
  let invokeCost = parseFloat(process.env.AWS_LAMBDA_INVOKE_COST);

  // calculate and record cost for each updated record
  // TODO - note all calcs are currently assuming AWS Lambda
  event.Records.forEach(function(record) {

    console.log('DynamoDB Record: %j', record.dynamodb);
    let requestIdValue = record.dynamodb.NewImage.RequestId.S;
    let billedDurationValue = record.dynamodb.NewImage.BilledDuration.N;
    let memorySizeValue = record.dynamodb.NewImage.MemorySize.N;
    let languageRuntimeValue = record.dynamodb.NewImage.LanguageRuntime.S;

    let billedGigabits = memorySizeValue / 1024;
    let billedSeconds = billedDurationValue / 1000;
    let gigabitSeconds = billedGigabits * billedSeconds;  
    let gigabitSecondsCost = gigabitSeconds * gbSecondCost;
    let functionCostValue = invokeCost + gigabitSecondsCost;
    
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
