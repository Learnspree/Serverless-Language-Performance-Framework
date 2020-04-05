#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -e environment [-b create-base-path-mapping] [-d api.gateway.custom.domain.com]"
   exit 1 # Exit script after printing help
}

while getopts "be:d:" opt
do
   case "$opt" in
      e ) environment="$OPTARG" ;;
      b ) createbasepathmapping="yes" ;;
      d ) apicustomdomainname="$OPTARG" ;;
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
if [ -n "$createbasepathmapping" ]
then
   if [ -z "$apicustomdomainname" ] 
   then
      echo "Missing domain for creation of base path mapping";
      helpFunction
   fi

   echo "***** SPF API ($environment): running create_domain for $apicustomdomainname *****"
   npm install serverless-domain-manager --save-dev
   serverless create_domain --stage $environment --domain $apicustomdomainname
fi

# do the deploy
if [ -z "$apicustomdomainname" ] 
then
   serverless deploy -v --stage $environment
else
   serverless deploy -v --stage $environment --domain $apicustomdomainname
fi


echo "***** SPF API ($environment): finished sls deploy stage *****"