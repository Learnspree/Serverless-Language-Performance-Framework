'use strict';

/* eslint-disable no-param-reassign */

var appInsights = require("applicationinsights");
appInsights.setup();
var client = new appInsights.TelemetryClient();

module.exports.empty = function (context, nodeJSEmptyFunctionTimer) {

  // Using env variables to detect cold vs warm start
  let currentInvocationCount = parseInt(("INVOCATION_COUNT" in process.env) ? process.env.INVOCATION_COUNT : "0");
  context.log("currentInvocationCount: " + currentInvocationCount);
  let functionState = ((currentInvocationCount > 0) ? "warm" : "cold");
  process.env.INVOCATION_COUNT = currentInvocationCount + 1;
  context.log( functionState + " start");
  client.trackTrace({
    message: 'cold start state', 
    severity: appInsights.Contracts.SeverityLevel.Warning,
    properties: { "state" : functionState }
  });

  context.res = {
    // status: 200, /* Defaults to 200 */
    body: 'Empty azure node function executed successfully!',
  };

  context.done();
};
