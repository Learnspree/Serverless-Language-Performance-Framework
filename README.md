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
| Azure Functions Core Tools | 2.7.2254         | https://github.com/Azure/azure-functions-core-tools|
| Azure Resource Manager (ARM) Tools for VSCode | 0.8.4 | https://marketplace.visualstudio.com/items?itemName=msazurermtools.azurerm-vscode-tools |
| Powershell Plugin for VSCode | 2020.3.0 | https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell |

## Setup Environment
The following setup steps assume Mac OS X (all project development was done on this platform).
See table above for versions and links

1. Install Brew *(a package manager for MAC OS)*
2. Install Node *(via `brew install node`)*
3. Install AWS CLI 
4. Configure AWS Credentials for AWS CLI *(see links above)*
5. Install Serverless Framework *(via `npm install -g serverless`)*
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

### Azure Setup

If you want to additionally test Azure Functions (in addition to AWS Lambda) then follow these additional steps:
1. Setup Microsoft Azure Account
2. Install Azure CLI *(See link above or for macOS just use `brew update && brew install azure-cli`)*
3. Install Azure Powershell Core for MacOS *(See link above or for macOS just use `brew update && brew cask install powershell`)*
4. Install Azure "AZ" module on Powershell Core (via `pwsh` then `Install-Module -Name Az -AllowClobber -Scope AllUsers`)
5. Connect to Azure Account from Powershell using `Connect-AzAccount`
6. Install VSCode Azure Functions Plugin (see link in table above)
7. Install Azure Core Tools via `npm install -g azure-functions-core-tools@core --unsafe-perm true` (see VSCode links above)

#### Setup Azure Service Principal for Automated Deployments
These steps will allow the creation of service principal to be used to automate service deployments without need for manual login via Connect-AzAccount in powershell first. See [here](https://docs.microsoft.com/en-us/powershell/azure/create-azure-service-principal-azureps?view=azps-3.6.1&viewFallbackFrom=azps-1.3.0) for guide.

1. Run `pwsh` to start powershell
2. Run `Connect-AzAccount` and login to your Azure subscription
3. Run the following script to create a new username/password-based service principal (use a strong password!):
```
cd azure-test/arm
setup-azure-testing.ps1 "<strong-password>"
```

Notes:
* The created service principal can be viewed (with associated ApplicationId and TenantId needed for login calls) via the console in Azure Active Directory->App Registrations (or via Powershell/AzureCLI commands)
* The service principal created here has general 'Contributor' access to the entire subscription - so it's very permissive. This should be restricted somewhat in future releases.


## SPF API - Setting up Route53 / DNS & CloudFront Caching Pre-requisites

By default you must setup Route53 DNS and a Cloudfront distribution to cache API responses for retrieval of metrics data. In future, this will be turned off by default and you will just get the typical AWS API Gateway URL to access the API (e.g. `*.execute-api.us-east-1.amazonaws.com`).

Pre-requisites: *(there are many guides from AWS to show how to do this)*:
* Use AWS Route53 to register your new domain (e.g. `mynewdomainexample.com`).
* Create SSL certificate using ACM (AWS Certificate Manager) to match your domain. Use DNS verification mode.
* Note the `AcmCertificateArn` value of the cert created in the previou step. This will be passed to the spf-build script to specify your new certificate's ARN (e.g. `arn:aws:acm:us-east-1:<account-number>:certificate/<cert-id>`)
* You can also use the AWS CLI to retrieve your certifcate's ARN details: `aws acm list-certificates`

### What you will have after deployment (see next section)
* A cloudfront distribution to your regional API which is set up with a HTTPS certificate for your domain
* You also see new Route53 recordsets added to your existing PHZ (Private Hosted Zone) to map to the custom domain's cloudfront distribution for both IPv4 and IPv6 (A and AAAA respectively).

Test new domain link to API Gateway via Route53/Cloudfront (for example):

`curl -v "https://api.<domain>/dev/runtimes/java8/mean"`

# Setting up SPF API and AWS Testing

The easiest way to deploy the common SPF API and all the AWS test function components is to run the single aggregator script. For example:


```bash
cd /bin
./spf-build-aws.sh -e dev -c <acm-cert-arn-created-above> -d <api-domain-registered-above>
```

This script will build the three main components for AWS in parallel (so expect a mix of output during the build): SPF API, AWS Test Functions and AWS Logger (the glue between the test functions and the SPF API which stores the results). Additionally, you can (re)build/deploy invidual framework components as described in the sections that follow below.

## Build and Deploy - AWS Test Functions
This section describes how to re-build and re-deploy the individual target test functions only. These are contained in the folder "/aws-test/". For example, the AWS test for nodejs12x is located in "/aws-test/aws-service-nodejs12x". There is a single serverless yml file and associated build/remove shell scripts that are used to define and deploy all the aws empty test functions in the "aws-test" directory. Note, as with all build/remove scripts, there is also a "-prod" version to deploy the prod-stage tables/functions/api.

```bash
cd /aws-test

# the optional -t option below runs basic integration tests after deployment
./spf-build-aws-test.sh -e dev [-t]
```

Each target function will essentially be setup with two cloud-watch-batch based triggers, representing both cold-start and warm-start test schedules. The warm-start can be modified in the "/aws-test/aws-service-\<runtime\>/serverless.yml" file and the cold-start in "/aws-test/aws-burst-invoker/serverless.yml". These batch triggers will be disabled by default. Example below:

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
        runtime: python3.8
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

## Build and Deploy - SPF API

Build & Deploy the metrics persistance function (saves given metrics in DynamoDB table) which is exposed via API Gateway as a RESTful endpoing. Note you will need the ACM Cert ARN and Domain URL you manually created in pre-requisite steps (see previous details in this readme).

```bash
cd /spf-api
./spf-build-api.sh -e dev -c <acm-cert-arn-created-earlier> -d <domain-registered-earlier>
```

## Build and Deploy - AWS Logger Functions
Note there is also a "-prod" version to deploy the prod-stage tables/functions/api.

```bash
cd /aws-common
./spf-build-aws-logger-dev.sh
```

## End-to-End Test - AWS Lambda
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

## Initiate Full Scheduled Test - AWS Lambda
Start a scheduled test by enabling the appropriate cloudwatch events on the test target functions you want to measure. For convenience, to start a full test of warm and cold start:

```bash
cd /bin
./enable-all-aws-rules.sh -e dev
```
## Cancel Scheduled Testing - AWS
Do not forget to cancel testing or else they will continue to run indefinitely. Depending on the frequency of your test scenario, this could amount to a lot of function calls incurring cost. Be careful! 

```bash
cd /bin
./disable-all-aws-rules.sh -e dev
```

## Cleanup - AWS
To remove all cloud-formation stacks created in your AWS account (by the serverless framework) for the performance testing, follow these commands to remove all functions:

```bash
# removes default "dev" environment
cd /bin
./spf-remove-aws.sh -e dev
```
### Dynamo DB Table Removal (Optional)
Optionally, you can manually remove the dynamodb metrics table. Note: this will happen automatically when you run the "/bin/spf-remove-aws.sh" script which removes the "dev" environment (but not when running the production version of the script - the table is protected there).

**WARNING!!** This will remove all your test results!

```bash
aws dynamodb delete-table --table-name ServerlessFunctionMetrics-dev [--profile <aws-profile>]
```


# Setting up Azure Testing

Before performing any function deployments in azure, we need to setup a service principal that can be used in automated deployments. There is a script created for this. See usage below:

```bash
cd /azure-test/arm
pwsh setup-azure-testing.ps1 -servicePrincipalPass "<use-a-strong-password>"
```

## Azure Performance Logger Function
This function is triggered from metrics saved by Azure Insights into Azure Storage. It parses these and delivers to the AWS-hosted API to save the metrics. 

Note - this function only needs to be deployed once in a single region, but the ability is provided to choose that region with a parameter in the build script.

```bash
# Deploy the Azure Logs Performance Metric Parser Function
cd azure-common/azure-logger
./spf-build-azure-common.sh -r "East US" -p "my-service-principle-password"
```

## Azure Test Function Deployment
Serverless Framework is not used for Azure function deployment as it is for AWS. This is due to it's relatively basic Azure support compared to AWS. Instead, a single script can be used to build and deploy each azure test function app (one per runtime being tested): 

```bash
cd /azure-test/
./spf-build-azure-test.sh -r <region> -l <runtime> -p <service-principal-password> [-v <runtime-version>]

# Example:
./spf-build-azure-test.sh -r "Central US" -l "node" -p "my-service-principle-password" -v 12
```
There are multiple azure function apps in the SPF project - one for each runtime type as per azure standards. These are each contained in the folder "/azure-test/azure-service-\<runtime\>". Note, the Azure Functions tests for node runtime are located in two separate function apps (unlike .NET) e.g. "/azure-test/azure-service-coldstart-node". This is due to the detection method in node test function for cold vs warm start relying on environment variables.

"Continuous Export" of the application-insights data ('Request' data only) for the function-apps is automatically setup by the above scripts. This exports the test function execution metrics to the azure-logger's storage account, acting as a trigger for the logger function to parse and deliver the metrics to the main SPF data store behind the SPF API.

### Cold vs Warm Start Detection

A quick note to mention how Azure testing differes in this framework to the AWS testing. AWS allows in-built detection of warm vs cold start by the its default logging. Azure does not provide this so each test function must be specified as warm or cold. Any accidental warm-starts for the cold function (and vice-versa) will be ignored by the Azure logger function if it detects a 'failure' generated by the test function.

## Supported Azure Runtimes

Current supported runtime values are (all functions runtime v3):
* `node` (NodeJS - 10x, 12x)
* `dotnet` (csx)

Also *coming soon*:
* `python` (python3.6 and 3.8) - *coming soon*
* `java` (java8) 


## Initiate Full Schedule Test - Azure Functions
See commands below to check status of existing function apps and also start/stop the "azure-service-\<runtime\>" functionapps (one per runtime tested) which will enable and disable the warm/cold test functions and their associated timers.

### Start

```bash
cd /bin
./enable-all-azure-rules.sh -e dev
```

### Stop

```bash
cd /bin
./disable-all-azure-rules.sh -e dev
```

### Verify

```bash

# Verify results (example for csx runtime)
aws dynamodb query --table-name ServerlessFunctionMetrics-dev \
    --index-name "duration-index" \
    --key-condition-expression "LanguageRuntime = :runtime" \
    --expression-attribute-values "{\":runtime\": {\"S\": \"dotnet31csx\"}}"    

```

## Cleanup - Azure
To remove all Azure test-function resources, run the following script which will remove all resource-groups created for the test functions and their resources:

```bash
cd /azure-test
./spf-remove-azure-test.sh 
```

## Useful Links - Azure Functions

* [Automate Function App Deployment with ARM Template](https://docs.microsoft.com/en-us/azure/azure-functions/functions-infrastructure-as-code#consumption)
* [Zip deployment for Azure Functions](https://docs.microsoft.com/en-gb/azure/azure-functions/deployment-zip-push)
* [Azure Functions Runtime Versions](https://docs.microsoft.com/en-gb/azure/azure-functions/functions-versions)
* [Settings Reference for Azure Functions](https://docs.microsoft.com/en-gb/azure/azure-functions/functions-app-settings#functions_worker_runtime)
* [ARM Template Structure and Syntax](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-syntax)
* [Continuous Export Insights Schema](https://docs.microsoft.com/en-us/azure/azure-monitor/app/export-data-model)
* [App Insights Memory/Perf Data](https://github.com/Azure/Azure-Functions/wiki/Consumption-Plan-Cost-Billing-FAQ#how-can-i-access-execution-count-and-gb-seconds-programmatically)
* [Measuring the cost of Azure Functions](https://www.nigelfrank.com/blog/ask-the-expert-measuring-the-cost-of-azure-functions/)
* [Continuous Export for Azure Insights](https://docs.microsoft.com/en-us/azure/application-insights/app-insights-export-telemetry)
* [Managing your function app](https://docs.microsoft.com/en-us/azure/azure-functions/functions-how-to-use-azure-function-app-settings)