var assert = require('assert');

describe('Azure Logger', function() {

  describe('#processMultipleJSONRootStringTest()', function() {

    it('should replace {"request with ,{"request for any instances in the string', function() {
      let testString = '{"request":[{"id":"92024e2b05ceb642"';
      let expectedString = ',{"request":[{"id":"92024e2b05ceb642"';

      var logger = require( "../logger-function/handler.js" ).logger;
      let processedString = logger.processMultipleJSONRootString(testString);

      assert.equal(expectedString, processedString);
    });

  });

});