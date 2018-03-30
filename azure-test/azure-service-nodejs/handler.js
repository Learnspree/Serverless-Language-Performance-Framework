'use strict';

/* eslint-disable no-param-reassign */

module.exports.empty = function (context, nodeJSEmptyFunctionTimer) {

  context.res = {
    // status: 200, /* Defaults to 200 */
    body: 'Empty function executed successfully!',
  };

  context.done();
};
