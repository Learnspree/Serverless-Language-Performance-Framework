#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -e environment"
   echo -e "\t-e target environment (dev or prod)"
   exit 1 # Exit script after printing help
}

while getopts "te:" opt
do
   case "$opt" in
      e ) environment="$OPTARG" ;;
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$environment" ] 
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

if [[ $environment != "dev" ]] && [[ $environment != "prod" ]]; then
    echo "Some or all of the parameters are incorrect";
    helpFunction
fi

echo "***** SPF API ($environment): running build script *****"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "***** SPF API ($environment): running in $DIR *****"

# Build the .net core 2 metrics function
cd $DIR/lambda-metrics-service
dotnet add package AWSSDK.DynamoDBv2 --version 3.3.6
dotnet add package Amazon.Lambda.APIGatewayEvents
./build-macos.sh

echo "***** SPF API ($environment): finished build stage *****"

echo "***** SPF API ($environment): start test stage *****"

cd $DIR
python -m unittest discover -v 

echo "***** SPF API ($environment): finished test stage *****"


echo "***** SPF API ($environment): running sls deploy stage *****"

cd $DIR

# During serverless deploy, optionally setup custom domain base path mappings to map custom domain 
# (like 'api.serverlessperformance.net') to API Gateway AWS URL
npm install serverless-domain-manager --save-dev
serverless create_domain --stage $environment
serverless deploy -v --stage $environment

echo "***** SPF API ($environment): finished sls deploy stage *****"