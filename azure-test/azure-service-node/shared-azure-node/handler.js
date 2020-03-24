'use strict';

/* eslint-disable no-param-reassign */

module.exports.empty = function (context, nodeJSEmptyFunctionTimer) {

  // Using env variables to detect cold vs warm start
  context.log("Context: " + JSON.stringify(context));

  let currentInvocationCount = parseInt(("INVOCATION_COUNT" in process.env) ? process.env.INVOCATION_COUNT : "0");
  context.log("currentInvocationCount: " + currentInvocationCount);
  context.log(((currentInvocationCount > 0) ? "warm" : "cold") + " start");
  process.env.INVOCATION_COUNT = currentInvocationCount + 1;

  context.res = {
    // status: 200, /* Defaults to 200 */
    body: 'Empty azure node function executed successfully!',
  };

  context.done();
};
