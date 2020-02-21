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

echo "***** SPF: running cleanup script ($environment) *****"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "***** SPF: running in $DIR *****"

# serverless framework will remove the cloud-formation stack
cd $DIR/aws-service-dotnetcore2
serverless remove -v --stage $environment

cd $DIR/aws-service-go
serverless remove -v --stage $environment

cd $DIR/aws-service-java
serverless remove -v --stage $environment

cd $DIR/aws-service-nodejs
serverless remove -v --stage $environment

cd $DIR/aws-service-python
serverless remove -v --stage $environment

cd $DIR/aws-service-ruby
serverless remove -v --stage $environment

cd $DIR/aws-burst-invoker
serverless remove -v --stage $environment

echo "***** SPF: finished cleanup script ($environment) *****"