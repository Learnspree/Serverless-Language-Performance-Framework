'use strict';

/* eslint-disable no-param-reassign */

function invocationCountIncrement(context){
    invocationCountIncrement.counter++;
    context.log("counter:" + invocationCountIncrement.counter);

    if (invocationCountIncrement.counter > 1) {
      context.log("warm start");
    }
    else {
      context.log("cold start");
    }
}

invocationCountIncrement.counter = 0;

module.exports.empty = function (context, nodeJSEmptyFunctionTimer) {

  var invocationCountIncrementer = new invocationCountIncrement(context);  
  context.res = {
    // status: 200, /* Defaults to 200 */
    body: 'Empty azure node function executed successfully!',
  };

  context.done();
};
