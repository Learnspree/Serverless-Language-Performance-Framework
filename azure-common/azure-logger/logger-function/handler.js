'use strict';

const request = require('request');

/* eslint-disable no-param-reassign */

let emptyIfStringMetricNull = function (stringMetricValue) {
    return (stringMetricValue == null) ? "" : stringMetricValue;
};
  
let zeroIfNumericMetricNull = function (numericMetricValue) {
return (numericMetricValue == null) ? "" : numericMetricValue;
};

let memoryUsage = function (context, metricsData) {
    if (metricsData == null || metricsData.request == null || metricsData.context == null) {
      context.log('Invalid Metrics Data in memoryUsage()');
      return -1;
    } 

    /*
    // COMMENTING OUT UNTIL GET THIS WORKING

    // call the API for Azure Monitoring Data   
    request.get(
      "https://management.azure.com/subscriptions/1ad4a40f-7ad8-4789-8cdc-945e47748810/resourceGroups/azure-service-nodejs-rg/providers/Microsoft.Web/sites/azure-service-nodejs/providers/microsoft.insights/metrics?$filter=aggregationType eq 'Maximum' and startTime eq 2018-04-02T15:36:00Z and endTime eq 2018-04-02T16:38:00Z and timeGrain eq duration'PT1M'&api-version=2016-09-01",
      { json: true },
      function (error, response, body) {
        if (err) { context.log('Monitor API call error'); }
        context.log('Monitor API call completed');
    });*/

    // Default to 128
    return 128;
}

let usageMetrics = function (context, metricsData) {  
  
  if (metricsData == null || metricsData.request == null || metricsData.context == null) {
      context.log('Invalid Metrics Data');
      return null;
  }

  let requestIdValue = emptyIfStringMetricNull(metricsData.request[0].id);
  let durationValue = zeroIfNumericMetricNull(metricsData.request[0].durationMetric.value);
  // Divide duration as it's not in "ticks", not milliseconds. 10,000 ticks per ms.
  let durationValueMilliseconds = durationValue / 10000;
  let billedDurationValue = Math.ceil(durationValueMilliseconds/100)*100;
  let functionNameValue = emptyIfStringMetricNull(metricsData.request[0].name);
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

  // get memory usage via insights API (not provided in request data)
  let maxMemoryUsed = memoryUsage(context, metricsData);
  context.log('memory used: ' + maxMemoryUsed);

  let metricsInput = {
    timestamp : eventTimestamp, 
    requestId : requestIdValue,
    duration : durationValueMilliseconds,
    billedDuration : billedDurationValue, // Azure bills in 100ms blocks
    memorySize : maxMemoryUsed, // Assign same value as memory used as azure is dynamic not preset like AWS
    memoryUsed : maxMemoryUsed,  
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

  let decodedBlob = new TextDecoder().decode(metricsBlob);
  context.log("Received metrics: " + decodedBlob);

  let metricsDataPayload = usageMetrics(context, JSON.parse(decodedBlob));
  if (metricsDataPayload != null) 
  {
    // call the API to store data 
    // TODO - make this asynchronous call as we don't really care about the response too much.
    // Otherwise it's sitting idle waiting for the response     
    request.post(
      //process.env.POST_METRICS_URL,
      "https://api.serverlessperformance.net/dev/metrics",
      { json: metricsDataPayload },
      function (error, response, body) {
        context.log('API call completed');
    });
  }
  

  context.res = {
    // status: 200, /* Defaults to 200 */
    body: 'Logger function completed',
  };

  context.done();
};
