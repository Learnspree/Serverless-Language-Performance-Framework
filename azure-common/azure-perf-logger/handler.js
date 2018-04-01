'use strict';

const request = require('request');

/* eslint-disable no-param-reassign */

let emptyIfStringMetricNull = function (stringMetricValue) {
    return (stringMetricValue == null) ? "" : stringMetricValue;
};
  
let zeroIfNumericMetricNull = function (numericMetricValue) {
return (numericMetricValue == null) ? "" : numericMetricValue;
};

let usageMetrics = function (context, metricsData) {  
  
  if (metricsData == null || metricsData.request == null || metricsData.context == null) {
      return null;
  }

  let requestIdValue = emptyIfStringMetricNull(metricsData.request[0].id);
  let durationValue = zeroIfNumericMetricNull(metricsData.request[0].durationMetric.value);
  let functionNameValue = emptyIfStringMetricNull(metricsData.context.device.roleName);
  let eventTimestamp = emptyIfStringMetricNull(metricsData.context.data.eventTime);

  context.log('Id: ' + requestIdValue);
  context.log('Duration: ' + durationValue);
  context.log('Function Name: ' + functionNameValue);
  context.log('Time: ' + eventTimestamp);

  // Function Name -> Language Runtime last segment
  let functionNameParts = functionNameValue.split('-');
  let languageRuntimeValue = emptyIfStringMetricNull(functionNameParts[functionNameParts.length - 1]);
  context.log('Language Runtime: ' + languageRuntimeValue);


  let metricsInput = {
    timestamp : eventTimestamp, 
    requestId : requestIdValue,
    // Divide duration as it's not in "ticks", not milliseconds. 10,000 ticks per ms.
    duration : durationValue / 10000,
    billedDuration : -1, // Not immediately available as in AWS - OK not necessary. Cost Lambda will calculate this.
    memorySize : -1, // TODO
    memoryUsed : -1, // TODO
    functionName : functionNameValue,
    functionVersion : "#LATEST", // Just default for now
    languageRuntime : languageRuntimeValue,

    // following values hardcoded for now as we know we're running in Azure. 
    durationUnits : 'ms',
    memoryUnits : 'MB',
    serverlessPlatformName : 'Azure Functions'
  };

  context.log('Metrics Data: ' + JSON.stringify(metricsInput));

  return metricsInput;
};

module.exports.logger = function (context, metricsBlob) {
  context.log('Begin Logger Function');
  context.log("Received metrics: " + JSON.stringify(metricsBlob));

  let metricsDataPayload = usageMetrics(context, metricsBlob);

  // call the API to store data 
  // TODO - make this asynchronous call as we don't really care about the response too much.
  // Otherwise it's sitting idle waiting for the response     
  request.post(
    //process.env.POST_METRICS_URL,
    "https://f4fkn6ulhj.execute-api.us-east-1.amazonaws.com/dev/metrics",
    { json: metricsDataPayload },
    function (error, response, body) {
      context.log('API call completed');
  });

  context.res = {
    // status: 200, /* Defaults to 200 */
    body: 'Logger function completed',
  };

  context.done();
};
