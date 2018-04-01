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
  // Divide duration as it's not in "ticks", not milliseconds. 10,000 ticks per ms.
  let durationValueMilliseconds = durationValue / 10000;
  let billedDurationValue = Math.ceil(number/100)*100;
  let functionNameValue = emptyIfStringMetricNull(metricsData.context.device.roleName);
  let eventTimestamp = emptyIfStringMetricNull(metricsData.context.data.eventTime);

  context.log('Id: ' + requestIdValue);
  context.log('Duration: ' + durationValueMilliseconds);
  context.log('Function Name: ' + functionNameValue);
  context.log('Time: ' + eventTimestamp);
  context.log('Billed Duration: ' + billedDurationValue);

  // Function Name -> Language Runtime last segment
  let functionNameParts = functionNameValue.split('-');
  let languageRuntimeValue = emptyIfStringMetricNull(functionNameParts[functionNameParts.length - 1]);
  context.log('Language Runtime: ' + languageRuntimeValue);


  let metricsInput = {
    timestamp : eventTimestamp, 
    requestId : requestIdValue,
    duration : durationValueMilliseconds,
    billedDuration : billedDurationValue, // Azure bills in 100ms blocks
    memorySize : 128, // TODO - Defaulting to 128MB block minimum. TODO assign same value as memory used as azure is dynamic not preset like AWS
    memoryUsed : 128, // TODO - use https://docs.microsoft.com/en-us/rest/api/monitor/ to call API to get memory. See https://stackoverflow.com/questions/41128329/how-can-i-programmatically-access-azure-functions-usage-metrics
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
