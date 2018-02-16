'use strict';

const zlib = require('zlib');

module.exports.logger = (event, context, callback) => {
  
  console.log('Start LambdaMetricsCollector');
  console.log(JSON.stringify(event));
     
  const payload = new Buffer(event.awslogs.data, 'base64');
  zlib.gunzip(payload, (err, res) => {
      if (err) {
          console.log('ERROR LambdaMetricsCollector');
          return callback(err);
      }
      const parsed = JSON.parse(res.toString('utf8'));
      console.log('Decoded payload:', JSON.stringify(parsed));

      const response = {
        statusCode: 200,
        body: JSON.stringify({
          message: 'Successfully processed ${parsed.logEvents.length} log events.',
          input: event,
        }),
      };
    
      callback(null, response);
      // callback(null, 'Successfully processed ${parsed.logEvents.length} log events.');
  });

};
