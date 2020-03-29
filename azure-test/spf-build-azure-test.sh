#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -r region -p deploy_password -l runtime -e environment [-v runtime-version]"
   exit 1 # Exit script after printing help
}

environment = "dev"
runtimeVersion = "10" # default to 10 for node10x
while getopts "l:r:p:v:e:" opt
do
   case "$opt" in
      r ) region="$OPTARG" ;;
      l ) languageRuntime="$OPTARG" ;;
      p ) servicePrincipalPassword="$OPTARG" ;;
      v ) runtimeVersion="$OPTARG" ;;
      e ) environment="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$region" ] || [ -z "$servicePrincipalPassword" ] || [ -z "$languageRuntime" ] || [ -z "$environment" ]
then
   echo "Some or all of the required parameters are empty";
   helpFunction
fi

# app deployment method for a single runtime in a single region
deploy_azure_function_app () {

    echo ""
    echo "****************************************************"
    echo "***** SPF: running deploy - runtime: $1, region: $2, sourcepath: $3, environment: $4, state: $5, runtimeVersion: $6 ... *****"
    echo ""
    echo "***** SPF: deploy function app *****"
    pwsh -f deploy-test-function-app.ps1 -runtime "$1" -region "$2" -environment "$4" -teststate ${5:-"all"} -runtimeVersion ${6:-"10"}
    echo "***** SPF: deploy functions to function app *****"
    pwsh -f deploy-test-functions-to-function-app.ps1 -runtime "$1" -region "$2" -sourcepath "$3" -environment "$4" -teststate ${5:-"all"} -runtimeVersion ${6:-"10"}
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "***** SPF: running in $DIR/arm *****"
echo "***** SPF: running build script for Azure Function app for region '$region' *****"
echo ""

cd $DIR/arm

# Login with service principal 
echo "***** SPF: Logging in with SPFDeploymentServicePrincipal *****"
echo ""
pwsh -f login-with-service-principal.ps1 -servicePrincipalPass $servicePrincipalPassword

# Deploy the given runtime provided
if [ "$languageRuntime" == "node" ]
then
   # node is deployed in two separate function apps for cold/warm due to how it detects whether it's a cold or warm start state
   deploy_azure_function_app "$languageRuntime" "$region" "../azure-service-warmstart-$languageRuntime" "$environment" "warm" "$runtimeVersion"
   deploy_azure_function_app "$languageRuntime" "$region" "../azure-service-coldstart-$languageRuntime" "$environment" "cold" "$runtimeVersion"
else
   deploy_azure_function_app "$languageRuntime" "$region" "../azure-service-$languageRuntime" "$environment"
fi

echo "***** SPF: finished deploy stage for Azure Test Functions *****"