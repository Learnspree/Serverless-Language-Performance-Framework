'use strict';

const AWS = require('aws-sdk'); 
const dynamoDb = new AWS.DynamoDB.DocumentClient();

module.exports.costmetrics = (event, context, callback) => {

  // TODO - might be better to use DynamoDB streams rather than make metrics-lambda save and also send SNS
  // get SNS message
  var message = event.Records[0].Sns.Message;
  console.log('Message received from SNS:', message); 

  // TODO - parse the data I need from message to do cost calculation
  // - BilledDuration, MemorySize
  // - Combine with environment-variables specifying GB/second cost and invocation cost
  // - Calculate the cost using values above

  // FUTURE WORK - call out to the AWS Pricing API (see notes)
  // FUTURE WORK - create separate lambda to listen on SNS topic for price changes and store pricing in DynamoDB?

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
    // handle potential errors
    if (error) {
      console.error(error);
      callback(null, {
        statusCode: error.statusCode || 501,
        headers: { 'Content-Type': 'text/plain' },
        body: 'Couldn\'t create the cost data',
      });
      return;
    }

    // create a response
    const response = {
      statusCode: 200,
      body: JSON.stringify(params.Item),
    };
    callback(null, response);
  });
};
