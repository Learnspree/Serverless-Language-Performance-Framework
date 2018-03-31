'use strict';

const request = require('request');

/* eslint-disable no-param-reassign */

let usageMetrics = function () {  
  
  return {
    timestamp : Date.now(), // TODO - better to get timestamp as input from executing function via custom cloudwatch log entry
    requestId : "32423-23432kl-23432",
    duration : 10,
    billedDuration : 100,
    memorySize : 128,
    memoryUsed : 23,
    functionName : "empty Azure NodeJS",
    functionVersion : "1",

    // following values hardcoded for now as we know we're running in Azure. 
    durationUnits : 'ms',
    memoryUnits : 'MB',
    serverlessPlatformName : 'Azure Functions'
  };
};

module.exports.logger = function (context, metricsBlob) {
  context.log('Begin Logger Function');
  context.log("Received metrics: " + JSON.stringify(metricsBlob));

  /*
  Example:

  {
    "request": [
        {
            "id": "1fcbe98c-c276-45b0-aa76-828fed73fd86",
            "name": "empty",
            "count": 1,
            "responseCode": 0,
            "success": true,
            "durationMetric": {
                "value": 2475921,
                "count": 1,
                "min": 2475921,
                "max": 2475921,
                "stdDev": 0,
                "sampledValue": 2475921
            }
        }
    ],
    "internal": {
        "data": {
            "id": "4107e0a6-34f4-11e8-bf98-f1d602d7e637",
            "documentVersion": "1.61"
        }
    },
    "context": {
        "data": {
            "eventTime": "2018-03-31T15:00:00.005Z",
            "isSynthetic": false,
            "samplingRate": 100
        },
        "cloud": {},
        "device": {
            "type": "PC",
            "roleName": "azure-service-nodejs",
            "roleInstance": "9891672193580fbbf389519fae7178481fa4c1e74189ddd532e111ab83a74b68",
            "screenResolution": {}
        },
        "user": {
            "isAuthenticated": false
        },
        "session": {
            "isFirst": false
        },
        "operation": {
            "id": "1fcbe98c-c276-45b0-aa76-828fed73fd86",
            "parentId": "1fcbe98c-c276-45b0-aa76-828fed73fd86",
            "name": "empty"
        },
        "location": {
            "clientip": "0.0.0.0"
        },
        "custom": {
            "dimensions": [
                {
                    "Category": "Host.Results"
                },
                {
                    "{OriginalFormat}": "Executed '{FullName}' (Succeeded, Id={InvocationId})"
                },
                {
                    "Succeeded": "True"
                },
                {
                    "TriggerReason": "Timer fired at 2018-03-31T15:00:00.0059306+00:00"
                },
                {
                    "EndTime": "2018-03-31T15:00:00.240Z"
                },
                {
                    "FullName": "Functions.empty"
                },
                {
                    "LogLevel": "Information"
                }
            ]
        }
    }
}

  */

  // call the API to store data 
  // TODO - make this asynchronous call as we don't really care about the response too much.
  // Otherwise it's sitting idle waiting for the response     
  request.post(
    //process.env.POST_METRICS_URL,
    "https://f4fkn6ulhj.execute-api.us-east-1.amazonaws.com/dev/metrics",
    { json: usageMetrics() },
    function (error, response, body) {
      context.log('API call completed');
  });

  context.res = {
    // status: 200, /* Defaults to 200 */
    body: 'Logger function completed',
  };

  context.done();
};
