// FUTURE WORK - call out to the AWS Pricing API (see notes)
// FUTURE WORK - create separate lambda to listen on SNS topic for price changes and store pricing in DynamoDB?

'use strict';

const AWS = require('aws-sdk'); 
const dynamoDb = new AWS.DynamoDB.DocumentClient();

module.exports.costmetrics = (event, context, callback) => {

  // get data from dynamo-db stream records
  event.Records.forEach(function(record) {
    console.log(record.requestId);
    console.log(record.billedDuration);
    console.log('DynamoDB Record: %j', record.dynamodb);

    // TODO - parse the data I need from message to do cost calculation
    // - BilledDuration, MemorySize
    // - Combine with environment-variables specifying GB/second cost and invocation cost
    // - Calculate the cost using values above
    
    /* TODO - uncomment this code after proving dynamo-db stream is connected and 
       console.log messages above are working as expected */
    /*   
    // Create dynamo-db insert params from calculated data above
    const params = {
      TableName: process.env.DYNAMODB_COSTMETRICS_TABLE,
      Item: {
        requestId : uniqueRequestId,
        billedDuration : billedDurationValue,
        memorySize : memorySizeValue,
        functionName : functionNameValue,
        functionCost : functionCostValue
      }
    };

    // write the cost data to the database
    dynamoDb.put(params, (error) => {
      // log potential errors
      if (error) {
        console.error(error);
      }
    });    
  });*/

  callback(null, "Cost Metrics Lambda Finished");
};
