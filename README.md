# Serverless-Language-Performance-Framework
Related to MSc Applied IT Architecture Thesis @ Institute of Technology, Tallaght
This framework uses the serverless framework (from [http://www.serverless.com]) to test the relative performance and cost of different language implementations in AWS Lambda and ultimately other serverless platforms.

## Setup
Install AWS CLI and Serverless Framework (version 1.26.0 used).
All development primarly done so far on MAC OS.

## Testing
Test via serverless framework local invoke using:
''serverless invoke local --function logger -p lib/test-logger-input-raw.json''
