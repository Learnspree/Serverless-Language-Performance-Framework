# Serverless-Language-Performance-Framework
This project originated from a [paper](https://ieeexplore.ieee.org/abstract/document/8605773) on Serverless Performance as part of MSc Software Architecture @ [Technological University of Dublin (IT Tallaght)](https://www.it-tallaght.ie)

This project uses the [serverless framework](http://www.serverless.com) to test the relative performance and cost of different language implementations in AWS Lambda and other serverless platforms.

## Framework Overview
This framework uses a modular approach to allow plugging in different Serverless Platforms into an AWS-Lambda based processing engine that stores and analyzes the provided performance data. This is best illustrated in the diagram below:

<img alt="Serverless Language Performance Framework Diagram" src="./Framework%20Overview.png" width="360" height="400">

## Pre-Requisites
Use of this framework requires a valid AWS (Amazon Web Services) account. 
For Azure Functions testing, a valid Azure account is also required.

## Requirements
Development of this performance testing framework used the following packages and versions:

| Package                | Version              | Link                                       |
|------------------------|----------------------|--------------------------------------------|
| MacOS                  | Mojave (10.14.6)     |                                            |
| Brew (Homebrew)        | 2.1.6                | https://brew.sh                            |
| AWS CLI                | 1.16.190             | https://aws.amazon.com/cli                 |
| Serverless Framework   | 1.64.0               | https://serverless.com/framework/docs/getting-started/|
| Node                   | 12.5.0               | https://nodejs.org/en/                     |
| NPM                    | 6.13.6               | https://www.npmjs.com                      |
| .NET Core SDK / CLI    | 2.2.300              | https://dotnet.microsoft.com/download |
| Java8 (JDK)            | Oracle jdk1.8.0_212  | https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html|
| Java11 (JDK)           |  OpenJDK 11.0.2      | https://www.oracle.com/java/technologies/javase-jdk11-downloads.html |
| Apache Maven (for Java)| 3.6.1                | https://maven.apache.org/                  |
| Golang                 | 1.12.6               | https://golang.org/doc/install             |
| Azure CLI              | 2.1.0                | https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest|
| Powershell Core        | 7.0.0                | https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos?view=powershell-7 |
| Azure Functions VSCode | 0.18.1 (Preview)     | https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurefunctions|
| Azure Functions Core Tools | 2.7.1585         | https://github.com/Azure/azure-functions-core-tools|


## Setup AWS Lambda Testing
The following setup steps assume Mac OS X (all project development was done on this platform).
See table above for versions and links

1. Install Brew *(a package manager for MAC OS)*
2. Install Node *(via `brew install node`)*
3. Install AWS CLI 
4. Configure AWS Credentials for AWS CLI *(see links above)*
5. Install Serverless Framework *(via `npm install -g serverless`)*
6. Install Serverless Domain Manager plugin *(via `npm install serverless-domain-manager --save-dev`)*
6. Configure AWS Credentials for Serverless Framework *(see links above)*
7. Install .NET Core *(see links above)* (Note - for upgrade of existing .NET Core (if necessary) see https://docs.microsoft.com/en-us/dotnet/core/versions/remove-runtime-sdk-versions?tabs=macos)
8. Install Java JDK 8 and Java JDK 11 `brew cask install java8` and `brew cask install java11`. See below java setup details for more. 
9. Install Maven (3.x)
10. Install Golang (1.x)
11. Install pip for python2.7 (`sudo easy_install pip`)
12. Install boto3 to support python unit tests (`python -m pip install --user boto3`)

### Java Setup (8 and 11)
* Add the following aliases to .bash_profile:
```
export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8)
export JAVA_11_HOME=$(/usr/libexec/java_home -v11)

alias java8='export JAVA_HOME=$JAVA_8_HOME'
alias java11='export JAVA_HOME=$JAVA_11_HOME'

# default to Java 11
java11
```

* Reload .bash_profile for the aliases to take effect: `source ~/.bash_profile`

* Use the alias to change version as needed (the SPF build scripts do this automatically as needed):

```
$ java8
$ java -version
java version "1.8.0_212"
Java(TM) SE Runtime Environment (build 1.8.0_212-b10)
Java HotSpot(TM) 64-Bit Server VM (build 25.212-b10, mixed mode)
```

## Setup Azure Function Testing
**NOTE:** Currently the Azure test components may need some re-work to adapt to changes in the main SPF API hosted in AWS (see above section). Any issues will be resolved soon in future updates.

If you want to additionally test Azure Functions (in addition to AWS Lambda) then follow these additional steps:
1. Setup Microsoft Azure Account
2. Install Azure CLI *(See link above or for macOS just use `brew update && brew install azure-cli`)*
3. Install Azure Powershell Core for MacOS *(See link above or for macOS just use `brew update && brew cask install powershell`)*
3. Install Azure "AZ" module on Powershell Core (via `pwsh` then `Install-Module -Name Az -AllowClobber -Scope CurrentUser`)
3. Connect to Azure Account from Powershell using `Connect-AzAccount`
3. Install Azure Serverless Framework Plugin via `npm install -g serverless-azure-functions`
4. Install VSCode Azure Functions Plugin (see link above)
4. Install Azure Core Tools via `npm install -g azure-functions-core-tools@core --unsafe-perm true` (MacOS - Windows command differs (see VSCode links above)
5. Follow instructions to setup Azure CLI [credentials](https://serverless.com/framework/docs/providers/azure/guide/credentials/) to work with Serverless Framework 
6. Follow instructions to [setup](https://serverless.com/framework/docs/providers/azure/guide/quick-start/) Serverless Framework for Azure.


## Build & Deploy - AWS
The easiest way to deploy the common SPF API and all the AWS test function components is to run the single aggregator script (which has dev and prod versions). For example:


```bash
cd /bin
./spf-build-aws.sh
```

Alternatively, you can build/deploy invidual framework components as described in the sections that follow below.

**Route53 / DNS** (Optional)

Pre-requisites: *(there are many guides from AWS to show how to do this)*:
* Use AWS Route53 to register your new domain using AWS.
* Create SSL certificate using ACM to match your domain. Use DNS verification.

See https://serverless.com/blog/serverless-api-gateway-domain/ and https://seed.run/blog/how-to-set-up-a-custom-domain-name-for-api-gateway-in-your-serverless-app.html for instructions on using domain setup plugin for serverless. Steps:
* cd `<spf-api directory>`
* npm install serverless-domain-manager --save-dev
* serverless create_domain --stage dev
  * Now should see new custom domain added to "Custom Domains" list in API Gateway. However there are as yet no base path mappings.
* serverless deploy --stage dev
  * Now you see a /dev base path mapping on the new custom domain above.
  * You also see new Route53 recordsets added to your existing PHZ (Private Hosted Zone) to map to the custom domain's cloudfront distribution.

Test new domain link to API Gateway:

`curl https://api.<domain>/dev/runtimes/java8/mean`

### Build and Deploy all AWS Test Functions
This section describes how to re-build and re-deploy the individual target test functions only. These are contained in the folder "/aws-test/". For example, the AWS test for nodejs12x is located in "/aws-test/aws-service-nodejs12x". There is a single serverless yml file and associated build/remove shell scripts that are used to define and deploy all the aws empty test functions in the "aws-test" directory. Note, as with all build/remove scripts, there is also a "-prod" version to deploy the prod-stage tables/functions/api.

```bash
cd /aws-test
./spf-build-aws-test.sh -e dev [-t]
```

Each target function will essentially be setup with two cloud-watch-batch based triggers, representing both cold-start and warm-start test schedules. These can be modified in the "/aws-test/serverless.yml" file. These batch triggers will be disabled by default. Example below:

```
    awsnodejs12x:
        runtime: nodejs12.x
        handler: aws-service-nodejs12x/handler.emptytestnodejs12x
        events:
        - schedule: 
            rate: rate(1 minute)
            name: warmstart-nodejs12x-minute
            enabled: false    

    awsnodejs12x-coldstart:
        runtime: python3.7
        handler: aws-burst-invoker/handler.burst_invoker
        memorySize: ${self:custom.coldStartBatchMemory}
        events:
        - schedule: 
            rate: ${self:custom.coldStartInterval}
            name: coldstart-nodejs12x-hourly-burst
            enabled: false
            input:
                invokeCount: ${self:custom.coldStartBatchSize}
                targetFunctionName: aws-test-dev-awsnodejs12x                 
```

View "/aws-common/serverless.yml" to view the list of source cloud-watch-logs that are a trigger to measure performance of each target function deployed above. Example below for the node 12.x function:

```bash
    events:
      - cloudwatchLog:
          logGroup: '/aws/lambda/aws-test-dev-awsnodejs12x'
          filter: 'REPORT'
```

### Deploy API For Metrics Storage

Build & Deploy the metrics persistance function (saves given metrics in DynamoDB table) which is exposed via API Gateway as a RESTful endpoing. Note, as with all build/remove scripts, there is also a "-prod" version to deploy the prod-stage tables/functions/api.
```bash
cd /spf-api
./spf-build-api.sh -e dev
```

### Deploy AWS Logger Function 
Note, as with all build/remove scripts, there is also a "-prod" version to deploy the prod-stage tables/functions/api.

```bash
cd /aws-common
./spf-build-aws-logger.sh
```

## Build and Deploy - Azure (*Rework Needed*)
**NOTE:** Currently the Azure test components may need some re-work to adapt to changes in the main SPF API hosted in AWS (see above section). Any issues will be resolved soon in future updates.

### Azure NodeJS
Build and deploy the individual target test functions. These are contained in the folder "/azure-test/".
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

### End-to-End Test - AWS Lambda
Full end-to-end test measuring sample target function:
```bash
cd /aws-test
serverless invoke -f aws-warm-empty-nodejs12x -l [--aws-profile <aws-cli-profile>]

# Verify using get-maximum API endpoint
curl https://<api-gateway-url>.execute-api.us-east-1.amazonaws.com/dev/runtimes/nodejs12x/maximum

# Note - this should trigger (by default) the metrics gathering and logging lambda functions/API calls. 
# Check DynamoDB table "ServerlessFunctionMetrics-<env>" to validate.

# Examples below:
aws dynamodb query --table-name ServerlessFunctionMetrics-dev \
    --index-name "duration-index" \
    --key-condition-expression "LanguageRuntime = :runtime" \
    --expression-attribute-values "{\":runtime\": {\"S\": \"nodejs12x\"}}"

aws dynamodb scan --table-name ServerlessFunctionMetrics-dev --select "COUNT" \
    --filter-expression 'LanguageRuntime = :runtime AND #S = :state AND #T > :timestampvalue AND MemorySize = :memory' \
    --expression-attribute-names '{"#S":"State", "#T":"Timestamp"}' \
    --expression-attribute-values '{":runtime":{"S":"java8"}, ":memory":{"N":"128"},":state":{"S":"cold"}, ":timestampvalue":{"N":"1578873601000"}}' 

aws dynamodb query \
    --table-name ServerlessFunctionMetrics-dev \
    --key-condition-expression "LanguageRuntime = :runtime" \
    --projection-expression "LanguageRuntime, BilledDuration, ServerlessPlatformName" \
    --filter-expression '#S = :state AND #T > :timestampvalue AND MemorySize = :memory' \
    --expression-attribute-names '{"#S":"State", "#T":"Timestamp"}' \
    --expression-attribute-values '{":runtime":{"S":"java8"}, ":memory":{"N":"128"},":state":{"S":"warm"}, ":timestampvalue":{"N":"1578873601000"}}' 
```
Note potential values for runtime above:
* nodejs12x
* nodejs10x
* java8
* java11
* dotnet21
* go
* ruby25
* ruby27
* python36
* python38
* empty-csharp (azure csharp)
* empty-nodejs (azure nodejs)

### End-to-End Test - Azure Functions
Full end-to-end test measuring sample target function:
```bash
cd /azure-test/azure-service-nodejs
serverless invoke -f empty-nodejs -l 

# Verify results 
aws dynamodb query --table-name ServerlessFunctionMetrics-dev \
    --index-name "duration-index" \
    --key-condition-expression "LanguageRuntime = :runtime" \
    --expression-attribute-values "{\":runtime\": {\"S\": \"empty-nodejs\"}}"    

```

## Initiate Full Scheduled Test - AWS Lambda
Start a scheduled test by enabling the appropriate cloudwatch events on the test target functions you want to measure. For convenience, to start a full test of warm and cold start:

```bash
cd /bin
./enable-all-rules.sh -e dev
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

```bash
cd /bin
./disable-all-rules.sh -e dev
```

## Cleanup
To remove all cloud-formation stacks created in your AWS account (by the serverless framework) for the performance testing, follow these commands to remove all functions:

```bash
# removes default "dev" environment
# (a prod version of the script is also in /bin)
cd /bin
./spf-remove-aws.sh 
```
### Dynamo DB Table Removal (Optional)
Optionally, you can manually remove the dynamodb metrics table. Note: this will happen automatically when you run the "/bin/spf-remove-aws.sh" script which removes the "dev" environment (but not when running the production version of the script - the table is protected there).

**WARNING!!** This will remove all your test results!

```bash
aws dynamodb delete-table --table-name ServerlessFunctionMetrics-dev [--profile <aws-profile>]
```
