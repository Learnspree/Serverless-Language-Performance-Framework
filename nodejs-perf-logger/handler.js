'use strict';

// Note: Portions of CloudWatch logs parsing code from https://github.com/theburningmonk/lambda-logging-metrics-demo (Copyright (c) 2017 Yan Cui (MIT License))
const zlib = require('zlib');
const request = require('request');

// logGroup looks like this:
//    "logGroup": "/aws/lambda/service-env-funcName"
let functionName = function (logGroup) {
  return logGroup.split('/').reverse()[0];
};

// logStream looks like this:
//    "logStream": "2016/08/17/[76]afe5c000d5344c33b5d88be7a4c55816"
let lambdaVersion = function (logStream) {
  let start = logStream.indexOf('[');
  let end = logStream.indexOf(']');
  return logStream.substring(start+1, end);
};

let parseFloatWith = (regex, input) => {
  let res = regex.exec(input);
  return parseFloat(res[1]);
}

let parseRegex = (regex, input) => {
  let res = regex.exec(input);
  return res[1];
}

// a typical report message looks like this:
//    "REPORT RequestId: 3897a7c2-8ac6-11e7-8e57-bb793172ae75\tDuration: 2.89 ms\tBilled Duration: 100 ms \tMemory Size: 1024 MB\tMax Memory Used: 20 MB\t\n"
let usageMetrics = function (payload) {  
    let messageParts = payload.logEvents[0].message.split('\t');

    let uniqueRequestId     = parseRegex(/RequestId: (.*)/i, messageParts[0]);
    let actualDurationValue = parseFloatWith(/Duration: (.*) ms/i, messageParts[1]);
    let billedDurationValue = parseFloatWith(/Billed Duration: (.*) ms/i, messageParts[2]);
    let memorySizeValue     = parseFloatWith(/Memory Size: (.*) MB/i, messageParts[3]);
    let memoryUsedValue     = parseFloatWith(/Max Memory Used: (.*) MB/i, messageParts[4]);

    return {
      timestamp : Date.now(), // TODO - better to get timestamp as input from executing function via custom cloudwatch log entry
      requestId : uniqueRequestId,
      duration : actualDurationValue,
      billedDuration : billedDurationValue,
      memorySize : memorySizeValue,
      memoryUsed : memoryUsedValue,
      functionName : functionName(payload.logGroup),
      functionVersion : lambdaVersion(payload.logStream),
      durationUnits : 'ms',
      memoryUnits : 'MB',
      serverlessPlatformName : 'AWS Lambda'
    };
}

module.exports.logger = (event, context, callback) => {
     
  const payload = new Buffer(event.awslogs.data, 'base64');
  zlib.gunzip(payload, (err, res) => {
      if (err) {
          console.log('ERROR LambdaMetricsCollector');
          return callback(err);
      }

      const parsed = JSON.parse(res.toString('utf8'));
      const metrics = usageMetrics(parsed);
      console.log('metrics: ', JSON.stringify(metrics));

      // call the API to store data
      let responseCode = 200;
      request.post(
          'https://cjwam2lsp6.execute-api.us-east-1.amazonaws.com/dev/metrics',
          { json: metrics },
          function (error, response, body) {
              responseCode = response.statusCode;
              if (!error && response.statusCode == 200) {
                  console.log("SUCCESS")
              }
              else {
                console.log("An error occurred - " + error);
              }
          }
      );
    
      const response = {
        statusCode: responseCode,
        body: JSON.stringify({
          message: metrics
        })
      };
    
      callback(null, response);
  });

};
