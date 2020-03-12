#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -r region [-l runtime]"
   echo -e "\t-r [target Azure region].... (e.g. 'East US') [-l language-runtime]"
   exit 1 # Exit script after printing help
}

while getopts "l:r:" opt
do
   case "$opt" in
      r ) region="$OPTARG" ;;
      l ) languageRuntime="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$region" ] 
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# app deployment method for a single runtime in a single region
deploy_azure_function_app () {

    echo ""
    echo "****************************************************"
    echo "***** SPF: running deploy - runtime: $1, region: $2 ... *****"
    echo ""
    pwsh -f deploy-test-function-app.ps1 -runtime "$1" -region "$2"
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "***** SPF: running in $DIR/arm *****"
echo "***** SPF: running build script for Azure Function app for region '$region' *****"
echo ""

cd $DIR/arm

# Deploy just the given runtime if provided, otherwise deploy all
if [ -n "$languageRuntime" ]
then
   deploy_azure_function_app "$languageRuntime" "$region"
else
   # default - do the deployment of the function app in the target region per runtime
   deploy_azure_function_app "dotnet" "$region"
   deploy_azure_function_app "node" "$region"
   deploy_azure_function_app "python" "$region"
fi

echo "***** SPF: finished deploy stage for Azure Test Functions *****"