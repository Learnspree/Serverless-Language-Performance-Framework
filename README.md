# Serverless-Language-Performance-Framework
This project originated from a paper on Serverless Performance as part of MSc Applied IT Architecture @ [Technological University of Dublin (IT Tallaght)](https://www.it-tallaght.ie)

This project uses the [serverless framework](http://www.serverless.com) to test the relative performance and cost of different language implementations in AWS Lambda and other serverless platforms.

## Framework Overview
This framework uses a modular approach to allow plugging in different Serverless Platforms into an AWS-Lambda based processing engine that stores and analyzes the provided performance data. This is best illustrated in the diagram below:

<img alt="Serverless Language Performance Framework Diagram" src="https://github.com/Learnspree/Serverless-Language-Performance-Framework/blob/develop/Framework%20Overview.png" width="583" height="360">

## Pre-Requisites
Use of this framework requires a valid AWS (Amazon Web Services) account. 

## Requirements
Development of this performance testing framework used the following packages and versions:

| Package                | Version              | Link                                       |
|------------------------|----------------------|--------------------------------------------|
| MacOS                  | Sierra (10.12.6)     |                                            |
| Brew (Homebrew)        | 1.5.4                | https://brew.sh                            |
| AWS CLI                | 1.14.32              | https://aws.amazon.com/cli                 |
| Serverless Framework   | 1.26.1               | https://serverless.com/framework/docs/getting-started/|
| Node                   | 9.5.0                | https://nodejs.org/en/                     |
| NPM                    | 5.6.0                | https://www.npmjs.com                      |
| .NET Core Framework    | 2.0.5                | https://www.microsoft.com/net/learn/get-started/macos|
| .NET SDK / CLI         | 2.1.4                | https://www.microsoft.com/net/learn/get-started/macos|
| Java                   | Oracle jdk1.8.0_101  | http://www.oracle.com/technetwork/java/javaee/overview/index.html|
| Apache Maven (for Java)| 3.5.2                | https://maven.apache.org/                  |
| Golang                 | 1.10                 | https://golang.org/doc/install             |
| Azure CLI              | 2.0.29               | https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest|
| Azure Functions VSCode | 0.7.0 (Preview)      | https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurefunctions|
| Azure Functions Core Tools | 2.0.1-beta.24    | https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurefunctions|


## Setup AWS Lambda Testing
The following setup steps assume Mac OS X (all project development was done on this platform).
See table above for versions and links

1. Install Brew *(a package manager for MAC OS)*
2. Install Node *(via `brew install node`)*
3. Install AWS CLI 
4. Configure AWS Credentials for AWS CLI *(see links above)*
5. Install Serverless Framework *(via `npm install -g serverless`)*
6. Configure AWS Credentials for Serverless Framework *(see links above)*
7. Install .NET Core 2.0.5
8. Install required nuget packages for .NET Core *(commands in "build" section below for this)*
9. Install Java JDK 1.8
10. Install Maven (3.x)
11. Install Golang (1.x)

## Setup Azure Function Testing
If you want to additionally test Azure Functions (in addition to AWS Lambda) then follow these additional steps:
1. Setup Microsoft Azure Account
2. Install Azure CLI *(See link above or for macOS just use `brew update && brew install azure-cli`)*
3. Install Azure Serverless Framework Plugin via `npm install -g serverless-azure-functions`
4. Install VSCode Azure Functions Plugin (see link above)
4. Install Azure Core Tools via `npm install -g azure-functions-core-tools@core --unsafe-perm true` (MacOS - Windows command differs (see VSCode links above)
5. Follow instructions to setup Azure CLI [credentials](https://serverless.com/framework/docs/providers/azure/guide/credentials/) to work with Serverless Framework 
6. Follow instructions to [setup](https://serverless.com/framework/docs/providers/azure/guide/quick-start/) Serverless Framework for Azure.


## Build & Deploy - AWS
Build and deploy the individual target test functions. These are contained in the folder "/aws-test/". For example, the AWS test for node610 is located in "/aws-test/aws-service-node610". There is a central serverless yaml that is used to deploy all aws empty test functions.

### Build and Deploy all AWS Test Functions
```bash
cd /aws-test
serverless deploy -v --aws-profile <profile>
```

### Deploy All Functions

Each target function will by default be setup with two cloud-watch-batch based triggers, representing both cold-start and warm-start test schedules. These can be modified in the "/aws-test/serverless.yml" file. These batch triggers will be disabled by default. Enable one-at-a-time to ensure accurate cold or warm-start testing. Example below:

```
    events:
      - schedule: 
          rate: rate(1 hour)
          name: coldstart-node610-hourly
          enabled: false
      - schedule: 
          rate: rate(1 minute)
          name: warmstart-node610-minute
          enabled: false
```

View "/aws-common/nodejs-perf-logger/serverless.yml" to view the list of source cloud-watch-logs that are a trigger to measure performance of each target function deployed above. Example below for the node 6.10 function:

```bash
    events:
      - cloudwatchLog:
          logGroup: '/aws/lambda/aws-empty-test-functions-dev-awsnode610'
          filter: 'REPORT'
```

Build & Deploy the API-backed metrics persistance function (saves given metrics in DynamoDB table) and the Cost Function which is triggered off that table
```bash
cd /spf-api
./spf-build-api.sh
# Note - take a note of the API URL that is output from the deploy command. You'll need it to set up the logger below.
```

```bash
# Deploy the AWS CloudWatch Logs Lambda Performance Metric Parser Function
cd /aws-common/nodejs-perf-logger
./spf-build-aws-logger.sh
```

## Build and Deploy - Azure
Build and deploy the individual target test functions. These are contained in the folder "/azure-test/".

### Azure NodeJS
The Azure Functions test for nodeJS is located in "/azure-test/azure-service-nodejs":
```bash
cd /azure-test/aws-service-nodejs
npm install
serverless deploy -v 
```

### Azure CSharp (CSX)
The Azure Functions test code for CSharp Empty Function is located in "/azure-test/azure-service-csharp":

Note: Current issues with 2.0.1-beta of Core Tools integration with Node v9.5 (used for this project) means cannot use Azure Function Core Tools to deploy via CLI currently. Serverless framework 1.26.1 also not currently supporting csharp functions for Azure either. This test function will have to be currently deployed `manually` via Azure Portal within the existing FunctionApp created and configured for Azure NodeJS function above:
* Login to Azure Portal
* Select "Function Apps"
* Select existing “azure-service-test" function-app
* Add new CSharp Timer-based function to this existing function-app
    * Choose Language - C#
    * Choose name `empty-csharp`
    * Choose default timer cron of 1-per-hour `0 */60 * * * *`
* Copy the contents of `/azure-test/azure-service-csharp/empty-csharp/run.csx` to the generated run.csx file.

### Azure Insights Metrics Export
Setup "Continuous Export" of the application-insights data for the function-app just deployed.
To do this, follow the steps in this Azure Portal [Guide](https://docs.microsoft.com/en-us/azure/application-insights/app-insights-export-telemetry).

Note - choose following options when creating the continuous export (if storage account/container does not exist, the portal wizard will guide you through the steps to create them):
* Destination Storage Account Name = e.g. "azureperfmetrics" (these names are globally unique so you may need to adjust)
* Destination Storage Account Container = "perf-metrics"
* Data Types To Export: Turn ON "Request" data, turn OFF all others.

### Azure Performance Logger Function
This function is triggered from metrics saved by Azure Insights into Azure Storage. It parses these and delivers to the AWS-hosted API to save the metrics.

```bash
# Deploy the Azure Logs Performance Metric Parser Function
cd azure-common/azure-perf-logger
npm install request # just a one-off command - don't need to do this every build
serverless package 

# Connection String for azure storage: see access-keys in azure storage account created above>
serverless deploy -v 

# Important - Set AppSettings value on new perf-logger function so that it triggers from the StorageAccount generated for the test-target functions (empty-nodejs / empty-csharp). 
# See https://docs.microsoft.com/en-us/azure/storage/common/storage-create-storage-account#manage-your-storage-account  for guide on retrieving the storage connection string
az functionapp config appsettings set --name azure-perf-logger --resource-group azure-perf-logger-rg --settings AzurePerfLoggerStorage='<connection string retrieved from storage settings - see link in comment above'
```

## Validation
Test **logger** function via serverless framework local invoke using:
```bash
serverless invoke --function logger -p lib/test-logger-input-raw.json --postmetricsurl <api url>
# Note - optionally run locally with local option
```

Test **metrics** function (note: test example is via API Gateway - not Lambda directly - using `curl` below): 
```shell
1. cd /spf-api/lambda-metrics-service
2. aws apigateway get-rest-apis
3. curl -v -X POST -d@lib/test-metrics-service.json https://<aws-restapi-id>.execute-api.us-east-1.amazonaws.com/dev/metrics --header "Content-Type: application/json"

# example:
curl -v -X POST -d@lib/test-metrics-service.json https://ybt41omi9i.execute-api.us-east-1.amazonaws.com/dev/metrics --header "Content-Type: application/json"
```

### End-to-End Test - AWS Lambda
Full end-to-end test measuring sample target function:
```bash
cd /aws-test
serverless invoke -f awsnode610 -l --aws-profile <aws-cli-profile>

# Note - this should trigger (by default) the metrics gathering and logging lambda functions/API calls. 
# Check DynamoDB table "ServerlessFunctionMetrics" to validate.
# Example below to query for aws-java function but similar JSON files exist for other test functions queries.
aws dynamodb query --table-name ServerlessFunctionMetrics \
    --key-condition-expression "FunctionName = :v1" \
    --expression-attribute-values file://query-metrics-table-java.json

# Verify results - Costs (edit the json file for the request id you're looking for)
aws dynamodb query --table-name ServerlessFunctionCostMetrics  --key-condition-expression "RequestId = :v1" --expression-attribute-values file://query-costs-table-requestid.json
```
### End-to-End Test - Azure Functions
Full end-to-end test measuring sample target function:
```bash
cd /azure-test/azure-service-nodejs
serverless invoke -f empty-nodejs -l 

# Verify results - Metrics
aws dynamodb query --table-name ServerlessFunctionMetrics \
    --key-condition-expression "FunctionName = :v1" \
    --expression-attribute-values file://query-metrics-table-azure-node.json

# Verify results - Costs (edit the json file for the request id you're looking for)
aws dynamodb query --table-name ServerlessFunctionCostMetrics  --key-condition-expression "RequestId = :v1" --expression-attribute-values file://query-costs-table-requestid.json
```

## Initiate Full Scheduled Test - AWS Lambda
Start a scheduled test by enabling the appropriate filters on the test target functions you want to measure.
For example, to start a "cold-start" test on the aws-node610 test function, use the AWS CLI:

```bash
aws events enable-rule --name coldstart-node610-hourly --profile <aws profile>
```

All cold-start rules (also existing are scripts for all warm start rules):
```bash
cd /bin
./enable-all-coldstart-rules.sh [aws-profile-name (optional)]
```

## Initiate Full Schedule Test - Azure Functions
See commands below to check status of existing function apps and also start/stop the "azure-service-test" functionapp which will enable and disable the test functions and their associated timers.

```bash
az functionapp list

# Start Test
az functionapp start --name azure-service-test --resource-group azure-service-test-rg

# Stop Test
az functionapp stop --name azure-service-test --resource-group azure-service-test-rg
```

## Cancel Scheduled Testing - AWS
Do not forget to cancel testing or else they will continue to run indefinitely. Depending on the frequency of your test scenario, this could amount to a lot of function calls incurring cost. Be careful!

Individual rules:
```bash
aws events disable-rule --name coldstart-node610-hourly --profile <aws profile>
```

All rules (also existing are scripts for all cold or warm start rules):
```bash
cd /bin
./disable-all-rules.sh [aws-profile-name (optional)]
```

## Cleanup
To remove all cloud-formation stacks created in your AWS account (by the serverless framework) for the performance testing, follow these commands to remove all functions:

```bash
# Note - ensure that the logger function is removed first, as this has a dependency on the spf-api stack's API reference
cd /aws-common/nodejs-perf-logger
serverless remove --aws-profile <aws profile>

# Note - removal of the API will remove the DynamoDB tables (change retention option to "Retain" from "Delete" in the serverless.yml to change this before deployment). Removal will fail if you don't remove teh nodejs-perf-logger first.
cd /spf-api
serverless remove --aws-profile <aws profile>

cd aws-test
serverless remove --aws-profile <aws profile>
```
### Dynamo DB Table Removal (Optional)
Optionally, remove the dynamodb metrics table
**WARNING!!** This will remove all your test results!

```bash
aws dynamodb delete-table --table-name ServerlessFunctionMetrics --profile <aws-profile>
aws dynamodb delete-table --table-name ServerlessFunctionCostMetrics --profile <aws-profile>
```
