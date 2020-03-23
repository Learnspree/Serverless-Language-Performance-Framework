'use strict';

/* eslint-disable no-param-reassign */

function invocationCountIncrement(context){
    invocationCountIncrement.counter++;
    context.log((invocationCountIncrement.counter > 1) ? "warm" : "cold" + " start");
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
