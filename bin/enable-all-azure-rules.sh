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

# show output of what we're stopping
echo "Starting the following functionapp ids:"
echo ""
echo $(az functionapp list --query "[?state=='Stopped' && contains(id,'spf-azure-test') && contains(id,'$environment')].{id: id}")

# stop the function apps
functionidlist=$(az functionapp list --query "[?state=='Stopped' && contains(id,'spf-azure-test') && contains(id,'$environment')].{id: id}" --output tsv)
az functionapp start --ids $functionidlist


echo ""
echo "Finished enabling all azure rules for $environment environment."
echo ""