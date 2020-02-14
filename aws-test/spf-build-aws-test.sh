#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -e environment [-t]"
   echo -e "\t-e target environment (dev or prod)"
   exit 1 # Exit script after printing help
}

set -e

while getopts "te:" opt
do
   case "$opt" in
      e ) environment="$OPTARG" ;;
      t ) testing="test" ;;
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

echo "***** SPF: running build script ($environment) *****"


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "***** SPF: running in $DIR *****"

# build java8 test function
cd $DIR/aws-service-java8
mvn clean install -Dstage=$environment

# Build the .net core 2 test function
cd $DIR/aws-service-dotnetcore2
./build-macos.sh  # Different scripts exist for Windows or Linux

# For the golang test function
cd $DIR/aws-service-go
make

echo "***** SPF: finished build stage ($environment) *****"

echo "***** SPF: running sls deploy stage ($environment) *****"

cd $DIR
serverless deploy -v --stage $environment

echo "***** SPF: finished sls deploy stage ($environment) *****"

if [ -z $testing ]
then
    echo "***** SPF: skipping testing stage ($environment) *****"
else
    echo "***** SPF: running testing stage ($environment) *****"
    echo "***** SPF: testing each target function runs ok.... *****"
    cd $DIR
    sls invoke -f aws-warm-empty-dotnet21 --stage $environment
    sls invoke -f aws-warm-empty-go --stage $environment
    sls invoke -f aws-warm-empty-java8 --stage $environment
    sls invoke -f aws-warm-empty-nodejs12x --stage $environment
    sls invoke -f aws-warm-empty-nodejs10x --stage $environment

    sls invoke -f aws-warm-empty-python36 --stage $environment
    sls invoke -f aws-warm-empty-python38 --stage $environment
    sls invoke -f aws-warm-256-empty-dotnet21 --stage $environment
    sls invoke -f aws-warm-256-empty-go --stage $environment        
    sls invoke -f aws-warm-256-empty-java8 --stage $environment
    sls invoke -f aws-warm-256-empty-nodejs12x --stage $environment
    sls invoke -f aws-warm-256-empty-nodejs10x --stage $environment
    sls invoke -f aws-warm-256-empty-python36 --stage $environment
    sls invoke -f aws-warm-256-empty-python38 --stage $environment
    sls invoke -f aws-warm-512-empty-dotnet21 --stage $environment
    sls invoke -f aws-warm-512-empty-go --stage $environment        
    sls invoke -f aws-warm-512-empty-java8 --stage $environment
    sls invoke -f aws-warm-512-empty-nodejs12x --stage $environment
    sls invoke -f aws-warm-512-empty-nodejs10x --stage $environment
    sls invoke -f aws-warm-512-empty-python36 --stage $environment
    sls invoke -f aws-warm-512-empty-python38 --stage $environment

    sls invoke -f aws-cold-empty-dotnet21 --stage $environment
    sls invoke -f aws-cold-empty-go --stage $environment
    sls invoke -f aws-cold-empty-java8 --stage $environment
    sls invoke -f aws-cold-empty-nodejs12x --stage $environment
    sls invoke -f aws-cold-empty-nodejs10x --stage $environment
    sls invoke -f aws-cold-empty-python36 --stage $environment
    sls invoke -f aws-cold-empty-python38 --stage $environment
    sls invoke -f aws-cold-256-empty-dotnet21 --stage $environment
    sls invoke -f aws-cold-256-empty-go --stage $environment        
    sls invoke -f aws-cold-256-empty-java8 --stage $environment
    sls invoke -f aws-cold-256-empty-nodejs12x --stage $environment
    sls invoke -f aws-cold-256-empty-nodejs10x --stage $environment
    sls invoke -f aws-cold-256-empty-python36 --stage $environment
    sls invoke -f aws-cold-256-empty-python38 --stage $environment
    sls invoke -f aws-cold-512-empty-dotnet21 --stage $environment
    sls invoke -f aws-cold-512-empty-go --stage $environment        
    sls invoke -f aws-cold-512-empty-java8 --stage $environment
    sls invoke -f aws-cold-512-empty-nodejs12x --stage $environment
    sls invoke -f aws-cold-512-empty-nodejs10x --stage $environment
    sls invoke -f aws-cold-512-empty-python36 --stage $environment
    sls invoke -f aws-cold-512-empty-python38 --stage $environment

    echo "***** SPF: finished testing stage ($environment) *****"
fi
