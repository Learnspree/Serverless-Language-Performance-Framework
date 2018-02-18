# Serverless-Language-Performance-Framework
Related to MSc Applied IT Architecture Thesis @ Institute of Technology, Tallaght
This framework uses the serverless framework (from [http://www.serverless.com]) to test the relative performance and cost of different language implementations in AWS Lambda and ultimately other serverless platforms.

## Setup
Install AWS CLI and Serverless Framework (version 1.26.0 used).
All development primarly done so far on MAC OS.

Dynamo DB Tables can be created from the files in "dynamo-db-tables" directory using the commands:
* aws dynamodb create-table --cli-input-json file://create-table-metrics.json --region <region> --profile <aws cli profile>
* aws dynamodb create-table --cli-input-json file://create-table-platforms.json --region <region> --profile <aws cli profile>

## Testing
Test via serverless framework local invoke using:
serverless invoke local --function logger -p lib/test-logger-input-raw.json
