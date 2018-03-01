# Serverless-Language-Performance-Framework
MSc Applied IT Architecture @ [Institute of Technology, Tallaght](http://www.ittdublin.ie)

This project uses the [serverless framework](http://www.serverless.com) to test the relative performance and cost of different language implementations in AWS Lambda and other serverless platforms.

## Framework Overview
This framework uses a modular approach to allow plugging in different Serverless Platforms into an AWS-Lambda based processing engine that stores and analyzes the provided performance data. This is best illustrated in the diagram below:

<img alt="Serverless Language Performance Framework Diagram" src="https://github.com/Learnspree/Serverless-Language-Performance-Framework/blob/develop/Framework%20Overview.png" width="320" height="245">

## Pre-Requisites
Use of this framework requires a valid AWS (Amazon Web Services) account. 

## Requirements
Development of this performance testing framework used the following packages and versions:

| Package                | Version            | Link                                       |
|------------------------|--------------------|--------------------------------------------|
| MacOS                  | Sierra (10.12.6)   |                                            |
| Brew (Homebrew)        | 1.5.4              | https://brew.sh                            |
| AWS CLI                | 1.14.32            | https://aws.amazon.com/cli                 |
| Serverless Framework   | 1.26.0             | https://serverless.com/framework/docs/getting-started/|
| Node                   | 9.5.0              | https://nodejs.org/en/                     |
| NPM                    | 5.6.0              | https://www.npmjs.com                      |
| .NET Core Framework    | 2.0.5              | https://www.microsoft.com/net/learn/get-started/macos|
| .NET SDK / CLI         | 2.1.4              | https://www.microsoft.com/net/learn/get-started/macos|


## Setup
The following setup steps assume Mac OS X (all project development was done on this platform).
See table above for versions and links

1. Install Brew *(a package manager for MAC OS)*
2. Install Node *(via `brew install node`)*
3. Install AWS CLI 
4. Configure AWS Credentials for AWS CLI *(see links above)*
5. Install Serverless Framework *(via `npm install serverless`)*
6. Configure AWS Credentials for Serverless Framework *(see links above)*
7. Install .NET Core 2.0.5
8. Install required nuget packages for .NET Core *(commands in "build" section below for this)*
9. Deploy DynamoDB tables used by this framework:

```bash
aws dynamodb create-table --cli-input-json file://create-table-metrics.json --region <region> --profile <aws cli profile>
```

## Build
```bash
# Optionally modify nodejs-perf-logger/serverless.yml to change the source cloud-watch-log as a trigger to measure performance of your target function. Default example below:
    events:
      - cloudwatchLog:
          logGroup: '/aws/lambda/my-service-dev-hello'
          filter: 'REPORT'

# Build & Deploy the API-backed metrics persistance function (saves given metrics in DynamoDB table created earlier)
cd lambda-metrics-service
dotnet add package AWSSDK.DynamoDBv2 --version 3.3.6
dotnet add package Amazon.Lambda.APIGatewayEvents
./build-macos.sh
serverless deploy -v --aws-profile <aws cli profile>

# Deploy the AWS CloudWatch Logs Lambda Performance Metric Parser Function
cd nodejs-perf-logger
npm install request # just a one-off command - don't need to do this every build
npm install zlib # just one-off command also
serverless package --package aws-artifacts
serverless deploy --package aws-artifacts/ --aws-profile <aws cli profile> --postmetricsurl <api URL from lambda-metrics-service deploy step above>

```


## Validation
Test **logger** function via serverless framework local invoke using:
```bash
serverless invoke <optionally run locally with local option> --function logger -p lib/test-logger-input-raw.json
```

Test **metrics** function (note: test example is via API Gateway - not Lambda directly - using `curl` below): 
```shell
1. cd lambda-metrics-service
2. aws apigateway get-rest-apis
3. curl -v -X POST -d@lib/test-metrics-service.json https://<aws-restapi-id>.execute-api.us-east-1.amazonaws.com/dev/metrics --header "Content-Type: application/json"

# example:
curl -v -X POST -d@lib/test-metrics-service.json https://ybt41omi9i.execute-api.us-east-1.amazonaws.com/dev/metrics --header "Content-Type: application/json"
```

Full end-to-end test measuring sample target function:
```bash
1. cd my-service
2. serverless deploy -v --aws-profile <aws-cli-profile>
3. serverless invoke -f hello -l --aws-profile <aws-cli-profile>

# Note - this should trigger (by default) the metrics gathering and logging lambda functions/API calls. 
# Check DynamoDB table "ServerlessFunctionMetrics" to validate.
```
