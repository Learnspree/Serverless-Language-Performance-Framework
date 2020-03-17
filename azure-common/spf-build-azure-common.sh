#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -r region -p deploy_password"
   echo -e "\t-r [target Azure region].... (e.g. 'East US') -p deploy_password"
   exit 1 # Exit script after printing help
}

while getopts "r:p:" opt
do
   case "$opt" in
      r ) region="$OPTARG" ;;
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

# app deployment method for a logger function in a single region
deploy_azure_logger_app () {

    echo ""
    echo "****************************************************"
    echo "***** SPF: running azure logger deploy - region: $1 ... *****"
    echo ""
    echo "***** SPF: deploy logger function app *****"
    pwsh -f deploy-logger-function-app.ps1 -region "$1"
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "***** SPF: running in $DIR/arm *****"
echo "***** SPF: running build script for Azure Logger function app for region '$region' *****"
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
deploy_azure_logger_app "$region"

echo "***** SPF: finished deploy stage for Azure Logger Function *****"

