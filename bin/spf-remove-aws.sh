#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -e environment"
   exit 1 # Exit script after printing help
}

while getopts "e:" opt
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

echo "***** SPF: running full remove script *****"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "***** SPF: running in $DIR for environment $environment: *****"

# Remove the logger which takes test function log entries and delivers to the spf-api
echo "***** SPF: Remove Logger Handlers *****"
cd $DIR/../aws-common
./spf-remove-aws-logger-$environment.sh

# Remove spf-api next (logger depends on this stack's output)
echo "***** SPF: Remove API *****"
cd $DIR/../spf-api
./spf-remove-api.sh -e $environment

# Remove the test functions next (logger depends on this stack's log groups)
echo "***** SPF: Remove Test Functions *****"
cd $DIR/../aws-test
./spf-remove-aws-test.sh -e $environment

echo "***** SPF: Finished Remove *****"
