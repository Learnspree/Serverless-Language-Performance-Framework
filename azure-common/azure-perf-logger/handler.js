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
  context.log("Received metrics: ${metricsBlob}");

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
