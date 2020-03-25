#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -r region -p deploy_password -l runtime"
   echo -e "\t-r [target Azure region].... (e.g. 'East US') -p deploy_password -l language-runtime"
   exit 1 # Exit script after printing help
}

while getopts "l:r:p:" opt
do
   case "$opt" in
      r ) region="$OPTARG" ;;
      l ) languageRuntime="$OPTARG" ;;
      p ) servicePrincipalPassword="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$region" ] || [ -z "$servicePrincipalPassword" ] || [-z "$languageRuntime"]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# app deployment method for a single runtime in a single region
deploy_azure_function_app () {

    echo ""
    echo "****************************************************"
    echo "***** SPF: running deploy - runtime: $1, region: $2, sourcepath: $3, state: $4 ... *****"
    echo ""
    echo "***** SPF: deploy function app *****"
    pwsh -f deploy-test-function-app.ps1 -runtime "$1" -region "$2" -teststate ${4:-"all"}
    echo "***** SPF: deploy functions to function app *****"
    pwsh -f deploy-test-functions-to-function-app.ps1 -runtime "$1" -region "$2" -sourcepath "$3" -teststate ${4:-"all"}
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
   deploy_azure_function_app "$languageRuntime" "$region" "../azure-service-warmstart-$languageRuntime/*" "warm"
   deploy_azure_function_app "$languageRuntime" "$region" "../azure-service-coldstart-$languageRuntime/*" "cold"
else
   deploy_azure_function_app "$languageRuntime" "$region" "../azure-service-$languageRuntime/*"
fi

echo "***** SPF: finished deploy stage for Azure Test Functions *****"