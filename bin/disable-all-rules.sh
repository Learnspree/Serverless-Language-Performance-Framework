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

disable_rules_for_runtime () {
   echo "Starting disabling of $1 rules for $environment environment..."
   echo ""

   # Cold Start - covers all memory allocations
   aws events disable-rule --name coldstart-$1-$environment-hourly-burst && printf "."

   # Warm Start
   # 128 MB
   aws events disable-rule --name warmstart-$1-$environment-minute && printf "."

   # 256 MB
   aws events disable-rule --name warmstart-256-$1-$environment-minute && printf "."

   # 512 MB
   aws events disable-rule --name warmstart-512-$1-$environment-minute && printf "."

   echo ""
   echo "Finished disabling $1 rules for $environment environment."
   echo ""
} 

# call disable rules for each runtime
disable_rules_for_runtime "python36"
disable_rules_for_runtime "python38"
disable_rules_for_runtime "nodejs12x"
disable_rules_for_runtime "nodejs10x"
disable_rules_for_runtime "java8"
disable_rules_for_runtime "java11"
disable_rules_for_runtime "go"
disable_rules_for_runtime "dotnet21"
disable_rules_for_runtime "ruby25"
disable_rules_for_runtime "ruby27"

echo ""
echo "Finished disabling all rules for $environment environment."
echo ""