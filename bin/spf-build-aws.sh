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
if [ -z "$environment" ] || [ -z "$acmcertarn"] || [ -z "$apicustomdomainname"]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

if [[ $environment != "dev" ]] && [[ $environment != "prod" ]]; then
    echo "Some or all of the parameters are incorrect";
    helpFunction
fi

echo "***** SPF: running full build script *****"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "***** SPF: running in $DIR for environment $environment: *****"

# build spf-api first (logger depends on this stack's output)
echo "***** SPF: Build API *****"
cd $DIR/../spf-api
./spf-build-api.sh -e $environment -d $apicustomdomainname -c $acmcertarn & 

# Build the test functions next (logger depends on this stack's log groups)
echo "***** SPF: Build Test Functions *****"
cd $DIR/../aws-test
./spf-build-aws-test.sh -e $environment -t

# Finally build the logger which takes test function log entries and delivers to the spf-api
echo "***** SPF: Build Logger Handlers *****"
cd $DIR/../aws-common
./spf-build-aws-logger-$environment.sh

echo "***** SPF: Finished *****"
