#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -r region -p deploy_password [-l runtime]"
   echo -e "\t-r [target Azure region].... (e.g. 'East US') -p deploy_password [-l language-runtime]"
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
if [ -z "$region" ] || [ -z "$servicePrincipalPassword" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

remove_azure_function_app () {

    echo ""
    echo "****************************************************"
    echo "***** SPF: running remove - runtime: $1, region: $2 ... *****"
    echo ""
    pwsh -f remove-test-function-app.ps1 -runtime "$1" -region "$2"
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

# Remove just the given runtime if provided, otherwise remove all
if [ -n "$languageRuntime" ]
then
   remove_azure_function_app "$languageRuntime" "$region"
else
   # default - do the removal of the function app in the target region per runtime
   remove_azure_function_app "dotnet" "$region"
   remove_azure_function_app "node" "$region"
   remove_azure_function_app "python" "$region"
fi

echo "***** SPF: finished remove stage for Azure Test Functions *****"