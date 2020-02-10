#!/bin/bash

echo "***** SPF: running build script *****"
set -e

while getopts "t" opt
do
   case "$opt" in
      t ) testing="test" ;;
   esac
done

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "***** SPF: running in $DIR *****"

# build java8 test function
cd $DIR/aws-service-java8
mvn clean install -Dstage=dev

# Build the .net core 2 test function
cd $DIR/aws-service-dotnetcore2
./build-macos.sh  # Different scripts exist for Windows or Linux

# For the golang test function
cd $DIR/aws-service-go
make

echo "***** SPF: finished build stage *****"

echo "***** SPF: running sls deploy stage *****"

cd $DIR
serverless deploy -v

echo "***** SPF: finished sls deploy stage *****"

if [ -z $testing ]
then
    echo "***** SPF: skipping testing stage *****"
else
    echo "***** SPF: running testing stage *****"
    echo "***** SPF: testing each target function runs ok.... *****"
    cd $DIR
    sls invoke -f aws-warm-empty-dotnet21 --stage dev
    sls invoke -f aws-warm-256-empty-dotnet21 --stage dev
    sls invoke -f aws-warm-empty-go --stage dev
    sls invoke -f aws-warm-256-empty-go --stage dev
    sls invoke -f aws-warm-empty-java8 --stage dev
    sls invoke -f aws-warm-256-empty-java8 --stage dev
    sls invoke -f aws-warm-empty-nodejs12x --stage dev
    sls invoke -f aws-warm-256-empty-nodejs12x --stage dev
    sls invoke -f aws-warm-empty-python36 --stage dev
    sls invoke -f aws-warm-256-empty-python36 --stage dev

    sls invoke -f aws-cold-empty-dotnet21 --stage dev
    sls invoke -f aws-cold-256-empty-dotnet21 --stage dev
    sls invoke -f aws-cold-empty-go --stage dev
    sls invoke -f aws-cold-256-empty-go --stage dev
    sls invoke -f aws-cold-empty-java8 --stage dev
    sls invoke -f aws-cold-256-empty-java8 --stage dev
    sls invoke -f aws-cold-empty-nodejs12x --stage dev
    sls invoke -f aws-cold-256-empty-nodejs12x --stage dev
    sls invoke -f aws-cold-empty-python36 --stage dev
    sls invoke -f aws-cold-256-empty-python36 --stage dev

    echo "***** SPF: finished testing stage *****"
fi
