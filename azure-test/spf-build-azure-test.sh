#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -r region"
   echo -e "\t-r [target Azure region].... (e.g. 'East US')"
   exit 1 # Exit script after printing help
}

while getopts "r:" opt
do
   case "$opt" in
      r ) region="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$region" ] 
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

echo "***** SPF: running build script for Azure Test *****"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "***** SPF: running in $DIR *****"

echo "***** SPF: finished build stage *****"

echo "***** SPF: running deploy stage *****"

echo "Region: ${region}"
cd $DIR/arm
pwsh -f deploy-test-function-app.ps1 -runtime "dotnet" -region "$region"
#$DIR/arm/deploy-test-function-app.ps1 -runtime "node" -region "East US"
#$DIR/arm/deploy-test-function-app.ps1 -runtime "python" -region "East US"

echo "***** SPF: finished deploy stage *****"