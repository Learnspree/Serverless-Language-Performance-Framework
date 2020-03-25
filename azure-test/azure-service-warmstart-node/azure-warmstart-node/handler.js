'use strict';

/* eslint-disable no-param-reassign */
module.exports.empty = function (context, nodeJSEmptyFunctionTimer) {

  // Using env variables to detect cold vs warm start
  let currentInvocationCount = parseInt(("INVOCATION_COUNT" in process.env) ? process.env.INVOCATION_COUNT : "0");
  let functionState = ((currentInvocationCount > 0) ? "warm" : "cold");
  process.env.INVOCATION_COUNT = currentInvocationCount + 1;

  // write to log so app-insights can pick it up and trigger a match with the default logged function 'request' metrics picked up by the logger
  // this will write associated trace properties to app insights automatically including crucial "hostId" value
  context.log.error( "SPF Function State: " + functionState);

  context.res = {
    // status: 200, /* Defaults to 200 */
    body: 'Empty azure node function executed successfully!',
  };

  context.done();
};
