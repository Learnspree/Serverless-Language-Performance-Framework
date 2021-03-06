'use strict';

const request = require('request');

/* eslint-disable no-param-reassign */

let emptyIfStringMetricNull = function (stringMetricValue) {
  return (stringMetricValue == null) ? "" : stringMetricValue;
};
  
let zeroIfNumericMetricNull = function (numericMetricValue) {
  return (numericMetricValue == null) ? 0.0 : numericMetricValue;
};

let falseIfBooleanMetricNull = function (booleanMetricValue) {
  return (booleanMetricValue == null) ? false : booleanMetricValue;
};

let getWarmOrColdStart = function (functionNameParts) {
  // e.g. functionname is "azure-warmstart-node". We want the "warm" bit.
  let stateIndicator = functionNameParts[functionNameParts.length - 2];
  let state = stateIndicator.replace("start", "");
  if (state !== "warm" && state !== "cold") {
    return "unknown";
  }
  else {
    return state;
  }
}

// Sometimes metrics data are grouped in a single blob file but not formatted like
// a JSON array - instead it's a JSON file with multiple roots (invalid format).
// Change to an array in this case.
let processMultipleJSONRootString = function (jsonContent) {
  // add necessary elements to make the blob of request objects an array
  var modifiedJson = "{ \"functionmetrics\": [" + jsonContent + "] }";

  // add commas between "elements" in the array (i.e. request objects)
  modifiedJson = modifiedJson.replace(/{"request/g, ",{\"request");

  // remove the first comma added by the above command - first request object doesn't need it
  modifiedJson = modifiedJson.replace(/,{"request/, "{\"request");

  return modifiedJson;
}

let usageMetrics = function (context, metricsData) {  
  
  // first check if it was a successful test - we need to ignore test functions that ran cold instead of expected warm
  // and vice versa. These will have a failure state.
  let requestIdValue = emptyIfStringMetricNull(metricsData.request[0].id);
  let successfulTestRequest = falseIfBooleanMetricNull(metricsData.request[0].success);
  if (!successfulTestRequest) {
    context.log('Ignoring failed request id: ' + requestIdValue);
    return null;
  }

  // get core metrics
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
  let functionState = getWarmOrColdStart(functionNameParts);
  context.log('Language Runtime: ' + languageRuntimeValue);
  context.log('State: ' + functionState);

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
    state : functionState,
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

  let modifiedBlob = processMultipleJSONRootString(decodedBlob);
  context.log("Modified metrics: " + modifiedBlob);
  let metricsRequests = JSON.parse(modifiedBlob);

  if (metricsRequests == null || 
    metricsRequests.functionmetrics == null || 
    metricsRequests.functionmetrics[0] == null) 
  {
      context.log('Invalid Metrics Data');
      return null;
  }
  
  for (const metricsData of metricsRequests.functionmetrics ) {
    // check for valid data
    if (metricsData == null ||
        metricsData.request == null ||
        metricsData.context == null)
    {
          context.log('Invalid Metrics Data in array');
          continue;
    }

    // parse the metrics and send the POST request to SPF API
    let metricsDataPayload = usageMetrics(context, metricsData);
    if (metricsDataPayload != null) 
    {
      // call the API to store data 
      request.post(
        process.env.SPF_BASE_URL + "metrics",
        { json: metricsDataPayload },
        function (error, response, body) {
          context.log('API call completed: ');
          context.log('StatusCode:', response && response.statusCode); 
      });
    }
  }

  context.res = {
    // status: 200, /* Defaults to 200 */
    body: 'Logger function completed',
  };

  context.done();
};
