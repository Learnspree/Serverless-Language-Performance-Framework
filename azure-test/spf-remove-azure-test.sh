#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -r region -p deploy_password -l runtime -e environment"
   exit 1 # Exit script after printing help
}

while getopts "l:r:p:e:" opt
do
   case "$opt" in
      r ) region="$OPTARG" ;;
      l ) languageRuntime="$OPTARG" ;;
      p ) servicePrincipalPassword="$OPTARG" ;;
      e ) environment"$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$region" ] || [ -z "$servicePrincipalPassword" ] || [ -z "$languageRuntime"] || [ -z "$environment"]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

remove_azure_function_app () {

    echo ""
    echo "****************************************************"
    echo "***** SPF: running remove - runtime: $1, region: $2, environment: $3, state $4 ... *****"
    echo ""
    pwsh -f remove-test-function-app.ps1 -runtime "$1" -region "$2" -environment "$3" -teststate ${4:-"all"} 
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "***** SPF: running in $DIR/arm *****"
echo "***** SPF: running remove script for Azure Function app for region '$region' *****"
echo ""

cd $DIR/arm

# Login with service principal 
echo "***** SPF: Logging in with SPFDeploymentServicePrincipal *****"
echo ""
pwsh -f login-with-service-principal.ps1 -servicePrincipalPass $servicePrincipalPassword

# Remove the given runtime provided
if [ "$languageRuntime" == "node" ]
then
   # node is deployed in two separate function apps for cold/warm due to how it detects whether it's a cold or warm start state
   remove_azure_function_app "$languageRuntime" "$region" "$environment" "warm" 
   remove_azure_function_app "$languageRuntime" "$region" "$environment" "cold" 
else
   remove_azure_function_app "$languageRuntime" "$region" "$environment"
fi

echo "***** SPF: finished remove stage for Azure Test Functions *****"