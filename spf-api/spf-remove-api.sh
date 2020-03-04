#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -e environment"
   echo -e "\t-e target environment (dev or prod) [-b <base path mapping for custom api domain]"
   exit 1 # Exit script after printing help
}

while getopts "be:" opt
do
   case "$opt" in
      e ) environment="$OPTARG" ;;
      b ) basepathmapping="$OPTARG" ;;
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

echo "***** SPF API: running cleanup script *****"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "***** SPF API ($environment): running in $DIR *****"
cd $DIR

# optionally remove base path mapping for this environment from the api gateway custom domain
if [ -n "$basepathmapping" ]
then
   aws apigateway delete-base-path-mapping --domain-name "$basepathmapping" --base-path $environment
fi

# serverless framework will remove the cloud-formation stack
serverless remove -v --stage $environment

echo "***** SPF API ($environment): finished cleanup script *****"