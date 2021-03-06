#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -e environment -c acmcertarn -d api.mycustomdomain.com"
   exit 1 # Exit script after printing help
}

while getopts "e:d:c:" opt
do
   case "$opt" in
      e ) environment="$OPTARG" ;;
      d ) apicustomdomainname="$OPTARG" ;;
      c ) acmcertarn="$OPTARG" ;;
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$environment" ] || [ -z "$acmcertarn" ] || [ -z "$apicustomdomainname" ]
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

# do the deploy (assuming the api domain is something like 'api.example.com')
# by default hosted zone will be 'example.com.' - note trailing .
domain="$(cut -d'.' -f3 <<<"$apicustomdomainname")"
subdomain="$(cut -d'.' -f2 <<<"$apicustomdomainname")"
serverless deploy -v --stage $environment --domain $apicustomdomainname --acmcertarn $acmcertarn --hostedzone $subdomain.$domain.

echo "***** SPF API ($environment): finished sls deploy stage *****"