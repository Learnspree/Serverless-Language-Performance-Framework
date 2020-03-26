'use strict';

/* eslint-disable no-param-reassign */
module.exports.empty = function (context, nodeJSEmptyFunctionTimer) {

  // Using env variables to detect cold vs warm start
  let currentInvocationCount = parseInt(("INVOCATION_COUNT" in process.env) ? process.env.INVOCATION_COUNT : "0");
  let functionState = ((currentInvocationCount > 0) ? "warm" : "cold");
  process.env.INVOCATION_COUNT = currentInvocationCount + 1;

  // write state to log 
  context.log( "SPF Function State: " + functionState);

  context.res = {
    // status: 200, /* Defaults to 200 */
    body: 'Empty azure node function executed successfully!',
  };

  // set error for context.done() call - if we got an accidental warm-start (this is cold-start test) then ignore the results
  // passing 'null' to context.done indicates everything ran OK
  let errorMessage = functionState == "warm" ? "Warm start detected - ignore results for cold-start test function" : null;
  context.done(errorMessage);
};
