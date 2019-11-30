#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -e environment"
   echo -e "\t-e target environment (dev or prod)"
   exit 1 # Exit script after printing help
}

while getopts "e:" opt
do
   case "$opt" in
      e ) environment="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$environment" ] 
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

if [[ $environment != "dev" ]] && [[ $environment != "prod" ]]; then
    echo "Some or all of the parameters are incorrect";
    helpFunction
fi

aws events enable-rule --name warmstart-node810-$environment-minute 
aws events enable-rule --name warmstart-java8-$environment-minute 
aws events enable-rule --name warmstart-dotnet21-$environment-minute 
aws events enable-rule --name warmstart-python3-$environment-minute 
aws events enable-rule --name warmstart-golang-$environment-minute 
aws events enable-rule --name coldstart-python36-$environment-hourly-burst 
aws events enable-rule --name coldstart-node810-$environment-hourly-burst 
aws events enable-rule --name coldstart-java8-$environment-hourly-burst 
aws events enable-rule --name coldstart-go-$environment-hourly-burst 
aws events enable-rule --name coldstart-dotnet21-$environment-hourly-burst 