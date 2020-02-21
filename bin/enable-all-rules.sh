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

enable_rules_for_runtime () {
   echo "Starting enabling of $1 rules for $environment environment..."
   echo ""

   # Cold Start - covers all memory allocations
   aws events enable-rule --name coldstart-$1-$environment-hourly-burst && printf "."

   # Warm Start
   # 128 MB
   aws events enable-rule --name warmstart-$1-$environment-minute && printf "."

   # 256 MB
   aws events enable-rule --name warmstart-256-$1-$environment-minute && printf "."

   # 512 MB
   aws events enable-rule --name warmstart-512-$1-$environment-minute && printf "."

   echo ""
   echo "Finished enabling $1 rules for $environment environment."
   echo ""
} 

# call enable rules for each runtime
enable_rules_for_runtime "python36"
enable_rules_for_runtime "python38"
enable_rules_for_runtime "nodejs12x"
enable_rules_for_runtime "nodejs10x"
enable_rules_for_runtime "java8"
enable_rules_for_runtime "go"
enable_rules_for_runtime "dotnet21"
enable_rules_for_runtime "ruby25"
enable_rules_for_runtime "ruby27"

echo ""
echo "Finished enabling all rules for $environment environment."
echo ""