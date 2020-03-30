#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -r region -p deploy_password -e environment"
   exit 1 # Exit script after printing help
}

while getopts "r:p:e:" opt
do
   case "$opt" in
      r ) region="$OPTARG" ;;
      p ) servicePrincipalPassword="$OPTARG" ;;
      e ) environment="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$region" ] || [ -z "$servicePrincipalPassword" ] || [ -z "$environment" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

remove_azure_function_app () {

    echo ""
    echo "****************************************************"
    echo "***** SPF: running remove - region: $1, environment: $2.... *****"
    echo ""
    pwsh -f remove-logger-function-app.ps1 -region "$1" -environment ${2:-"dev"} 
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "***** SPF: running in $DIR/arm *****"
echo "***** SPF: running remove script for Azure Function logger for region '$region' *****"
echo ""

# Login with service principal 
echo "***** SPF: Logging in with SPFDeploymentServicePrincipal *****"
echo ""
cd $DIR/../azure-test/arm
pwsh -f login-with-service-principal.ps1 -servicePrincipalPass $servicePrincipalPassword

# Remove the given runtime provided
cd $DIR/arm
remove_azure_function_app "$region" "$environment" 

echo "***** SPF: finished remove stage for Azure Logger Function *****"