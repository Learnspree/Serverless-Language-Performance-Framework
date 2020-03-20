'use strict';

const request = require('request');

/* eslint-disable no-param-reassign */

let emptyIfStringMetricNull = function (stringMetricValue) {
    return (stringMetricValue == null) ? "" : stringMetricValue;
};
  
let zeroIfNumericMetricNull = function (numericMetricValue) {
return (numericMetricValue == null) ? 0.0 : numericMetricValue;
};

let usageMetrics = function (context, metricsData) {  
  
  if (metricsData == null || metricsData.request == null || metricsData.context == null) {
      context.log('Invalid Metrics Data');
      return null;
  }

  let requestIdValue = emptyIfStringMetricNull(metricsData.request[0].id);
  let durationValue = zeroIfNumericMetricNull(metricsData.request[0].durationMetric.value);
  let functionNameValue = emptyIfStringMetricNull(metricsData.request[0].name);
  let eventTimestamp = emptyIfStringMetricNull(metricsData.context.data.eventTime);

  // Divide duration as it's not in "ticks", not milliseconds. 10,000 ticks per ms.
  let durationValueMilliseconds = durationValue / 10000;
  let billedDurationValue = Math.ceil(durationValueMilliseconds/100)*100;

  // Subtract init-duration from the total duration provided in the "durationValue" metric
  // Use "FunctionExecutionTimeMs" as the actual execution duration
  let functionExecutionDimensions = metricsData.context.custom.dimensions.filter(dim => { return dim.FunctionExecutionTimeMs != null })
  console.log(JSON.stringify(functionExecutionDimensions));
  let functionExecutionDuration = parseFloat(emptyIfStringMetricNull(functionExecutionDimensions[0].FunctionExecutionTimeMs));
  let functionInitDuration = durationValueMilliseconds - functionExecutionDuration;


  context.log('Id: ' + requestIdValue);
  context.log('Duration: ' + functionExecutionDuration);
  context.log('Init Duration: ' + functionInitDuration);
  context.log('Function Name: ' + functionNameValue);
  context.log('Time: ' + eventTimestamp);
  context.log('Billed Duration: ' + billedDurationValue);

  // Function Name -> Language Runtime last segment
  let functionNameParts = functionNameValue.split('-');
  let languageRuntimeValue = emptyIfStringMetricNull(functionNameParts[functionNameParts.length - 1]);
  context.log('Language Runtime: ' + languageRuntimeValue);

  // hardcoding memory to 128 as minimum billable amount - all empty functions tested will fall under this
  // alternative is complicated API calls to Azure Monitor
  let maxMemoryUsed = 128;

  let metricsInput = {
    timestamp : Date.parse(eventTimestamp), 
    requestId : requestIdValue,
    duration : functionExecutionDuration,
    billedDuration : billedDurationValue, // Azure bills in 100ms blocks
    memorySize : maxMemoryUsed, // Assign same value as memory used as azure is dynamic not preset like AWS
    memoryUsed : maxMemoryUsed,  
    functionName : functionNameValue,
    functionVersion : "#LATEST", // Just default for now
    languageRuntime : languageRuntimeValue,

    // following values temporarily hardcoded until we can work out how to calculate them in Azure like we do in AWS
    state : 'warm',
    initDuration : functionInitDuration,

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
