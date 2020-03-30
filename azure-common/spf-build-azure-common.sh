#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -r region -p deploy_password -e environment (dev/prod)"
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

# app deployment method for a logger function in a single region
deploy_azure_logger_app () {

    echo ""
    echo "****************************************************"
    echo "***** SPF: running azure logger deploy - region: $1, env: $2 ... *****"
    echo ""
    echo "***** SPF: deploy logger function app *****"
    pwsh -f deploy-logger-function-app.ps1 -region "$1" -environment "$2"
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "***** SPF: running in $DIR/arm *****"
echo "***** SPF: running build script for Azure Logger function app ($environment) for region '$region' *****"
echo ""

# install node dependencies (build phase)
cd $DIR/azure-logger
npm install

# Login with service principal 
cd $DIR/../azure-test/arm
echo "***** SPF: Logging in with SPFDeploymentServicePrincipal *****"
echo ""
pwsh -f login-with-service-principal.ps1 -servicePrincipalPass $servicePrincipalPassword

# deploy the logger app
cd $DIR/arm
deploy_azure_logger_app "$region" "$environment"

echo "***** SPF: finished deploy stage for Azure Logger Function *****"

