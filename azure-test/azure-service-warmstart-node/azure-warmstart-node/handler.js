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

  // set error for context.done() call - if we got an accidental cold-start (this is warm-start test function) then ignore the results
  // passing 'null' to context.done indicates everything ran OK
  let errorMessage = functionState == "cold" ? "Cold start detected - ignore results for warm-start test function" : null;
  context.done(errorMessage);
};
