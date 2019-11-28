if [ $# -eq 0 ]
  then
    echo "No arguments supplied - using default aws cli profile"
    aws events enable-rule --name warmstart-node810-prod-minute 
    aws events enable-rule --name warmstart-java8-prod-minute 
    aws events enable-rule --name warmstart-dotnet21-prod-minute
    aws events enable-rule --name warmstart-python3-prod-minute
    aws events enable-rule --name warmstart-golang-prod-minute
    aws events enable-rule --name coldstart-python36-prod-hourly-burst
    aws events enable-rule --name coldstart-node810-prod-hourly-burst
    aws events enable-rule --name coldstart-java8-prod-hourly-burst
    aws events enable-rule --name coldstart-go-prod-hourly-burst
    aws events enable-rule --name coldstart-dotnet21-prod-hourly-burst
  else
    echo "Using aws cli profile '$1'"
    aws events enable-rule --name warmstart-node810-prod-minute --profile $1 &
    aws events enable-rule --name warmstart-java8-prod-minute --profile $1 &
    aws events enable-rule --name warmstart-dotnet21-prod-minute --profile $1 &
    aws events enable-rule --name warmstart-python3-prod-minute --profile $1 &
    aws events enable-rule --name warmstart-golang-prod-minute --profile $1 &
    aws events enable-rule --name coldstart-python36-prod-hourly-burst --profile $1 &
    aws events enable-rule --name coldstart-node810-prod-hourly-burst --profile $1 &
    aws events enable-rule --name coldstart-java8-prod-hourly-burst --profile $1 &
    aws events enable-rule --name coldstart-go-prod-hourly-burst --profile $1 &
    aws events enable-rule --name coldstart-dotnet21-prod-hourly-burst --profile $1 &
fi