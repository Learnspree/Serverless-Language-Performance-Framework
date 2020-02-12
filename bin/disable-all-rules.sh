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

# Cold Start - covers all memory allocations
aws events disable-rule --name coldstart-python36-$environment-hourly-burst 
aws events disable-rule --name coldstart-nodejs12x-$environment-hourly-burst 
aws events disable-rule --name coldstart-java8-$environment-hourly-burst 
aws events disable-rule --name coldstart-go-$environment-hourly-burst 
aws events disable-rule --name coldstart-dotnet21-$environment-hourly-burst 

# Warm Start
# 128 MB
aws events disable-rule --name warmstart-nodejs12x-$environment-minute 
aws events disable-rule --name warmstart-java8-$environment-minute 
aws events disable-rule --name warmstart-dotnet21-$environment-minute 
aws events disable-rule --name warmstart-python36-$environment-minute 
aws events disable-rule --name warmstart-go-$environment-minute 

# 256 MB
aws events disable-rule --name warmstart-256-nodejs12x-$environment-minute 
aws events disable-rule --name warmstart-256-java8-$environment-minute 
aws events disable-rule --name warmstart-256-dotnet21-$environment-minute 
aws events disable-rule --name warmstart-256-python36-$environment-minute 
aws events disable-rule --name warmstart-256-go-$environment-minute 

# 512 MB
aws events disable-rule --name warmstart-512-nodejs12x-$environment-minute 
aws events disable-rule --name warmstart-512-java8-$environment-minute 
aws events disable-rule --name warmstart-512-dotnet21-$environment-minute 
aws events disable-rule --name warmstart-512-python36-$environment-minute 
aws events disable-rule --name warmstart-512-go-$environment-minute 