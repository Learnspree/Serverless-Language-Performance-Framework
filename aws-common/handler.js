'use strict';

// Note: Portions of CloudWatch logs parsing code from https://github.com/theburningmonk/lambda-logging-metrics-demo (Copyright (c) 2017 Yan Cui (MIT License))
const zlib = require('zlib');
const request = require('request');

// logGroup looks like this:
//    "logGroup": "/aws/lambda/service-env-funcName"
let functionName = function (logGroup) {
  return logGroup.split('/').reverse()[0];
};

// function name like this:
//    aws-empty-go
let languageRuntimeFromFunctionName = function (functionName) {
  return functionName.split('-').reverse()[0];
}

// logStream looks like this:
//    "logStream": "2016/08/17/[76]afe5c000d5344c33b5d88be7a4c55816"
let functionVersion = function (logStream) {
  let start = logStream.indexOf('[');
  let end = logStream.indexOf(']');
  return logStream.substring(start+1, end);
};

let parseFloatWith = (regex, input) => {
  let res = regex.exec(input);
  if (res == null)
    return NaN
  else
    return parseFloat(res[1]);
};

let parseRegex = (regex, input) => {
  let res = regex.exec(input);
  return res[1];
};

// a typical report message looks like this:
//    "REPORT RequestId: 3897a7c2-8ac6-11e7-8e57-bb793172ae75\tDuration: 2.89 ms\tBilled Duration: 100 ms \tMemory Size: 1024 MB\tMax Memory Used: 20 MB\tInit Duration: 234 ms\t\n"
let usageMetrics = function (eventPayload, functionNameValue, functionVersionValue) {  
    let messageParts = eventPayload.message.split('\t');

    let uniqueRequestId     = parseRegex(/RequestId: (.*)/i, messageParts[0]);
    let actualDurationValue = parseFloatWith(/Duration: (.*) ms/i, messageParts[1]);
    let billedDurationValue = parseFloatWith(/Billed Duration: (.*) ms/i, messageParts[2]);
    let memorySizeValue     = parseFloatWith(/Memory Size: (.*) MB/i, messageParts[3]);
    let memoryUsedValue     = parseFloatWith(/Max Memory Used: (.*) MB/i, messageParts[4]);

    // Init Duration only in log entry if Cold Start
    let initDurationValue   = parseFloatWith(/Init Duration: (.*) ms/i, messageParts[5]); 
    let isWarmStart         = isNaN(initDurationValue); 

    return {
      timestamp : Date.now(), // TODO - better to get timestamp as input from executing function via  cloudwatch log entry
      requestId : uniqueRequestId,
      duration : actualDurationValue,
      billedDuration : billedDurationValue,
      memorySize : memorySizeValue,
      memoryUsed : memoryUsedValue,
      functionName : functionNameValue,
      functionVersion : functionVersionValue,
      languageRuntime : languageRuntimeFromFunctionName(functionNameValue),
      initDuration : isWarmStart ? 0 : initDurationValue,
      state: isWarmStart ? "warm" : "cold",

      // following values hardcoded for now as we know we're running in AWS Lambda. 
      // TODO - change these to environment variables for more flexibility
      durationUnits : 'ms',
      memoryUnits : 'MB',
      serverlessPlatformName : 'AWS Lambda'
    };
};

module.exports.logger = (event, context, callback) => {
     
  console.log(`Environment URL: ${process.env.POST_METRICS_URL + "/metrics"}`);
  
  const payload = new Buffer(event.awslogs.data, 'base64');
  zlib.gunzip(payload, (err, res) => {
      if (err) {
          console.log('ERROR LambdaMetricsCollector unzip');
          return callback(err);
      }

      const parsedPayload = JSON.parse(res.toString('utf8'));
      const functionNameValue = functionName(parsedPayload.logGroup);
      const functionVersionValue = functionVersion(parsedPayload.logStream);
      let successCount = 0;
      let failureCount = 0;

      console.log(`Logger detected invoke of ${functionNameValue}`);


      parsedPayload.logEvents.forEach(function (eventPayload) {
        const metrics = usageMetrics(eventPayload, functionNameValue, functionVersionValue);
        console.log(`metrics received for ${functionNameValue}`);

        // call the API to store data 
        // TODO - make this asynchronous call as we don't really care about the response too much.
        // Otherwise it's sitting idle waiting for the response     
        request.post(
          process.env.POST_METRICS_URL + "/metrics",
          { json: metrics },
          function (error, response, body) {
              console.log(`Body: ${body}, Response: ${response}, Error: ${error}`);
              if (!error && response.statusCode == 200) {
                  successCount++;
              }
              else {
                failureCount++;
              }
          });
      });
      
      // For Debugging - uncomment:
      console.log(`${successCount} logs saved, ${failureCount} logs failed to save. Check logs for any failures.`);

      // return overall response
      const response = {
        statusCode: failureCount == 0 ? 200 : 206,
        body: { }
      };
    
      callback(null, response);
  });

};
