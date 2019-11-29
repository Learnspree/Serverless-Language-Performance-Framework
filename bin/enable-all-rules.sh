if [ $# -eq 0 ]
  then
    echo "No arguments supplied - using default aws cli profile"
    aws events enable-rule --name warmstart-node810-dev-minute 
    aws events enable-rule --name warmstart-java8-dev-minute 
    aws events enable-rule --name warmstart-dotnet21-dev-minute
    aws events enable-rule --name warmstart-python3-dev-minute
    aws events enable-rule --name warmstart-golang-dev-minute
    aws events enable-rule --name coldstart-python36-dev-hourly-burst
    aws events enable-rule --name coldstart-node810-dev-hourly-burst
    aws events enable-rule --name coldstart-java8-dev-hourly-burst
    aws events enable-rule --name coldstart-go-dev-hourly-burst
    aws events enable-rule --name coldstart-dotnet21-dev-hourly-burst
  else
    echo "Using aws cli profile '$1'"
    aws events enable-rule --name warmstart-node810-dev-minute --profile $1 &
    aws events enable-rule --name warmstart-java8-dev-minute --profile $1 &
    aws events enable-rule --name warmstart-dotnet21-dev-minute --profile $1 &
    aws events enable-rule --name warmstart-python3-dev-minute --profile $1 &
    aws events enable-rule --name warmstart-golang-dev-minute --profile $1 &
    aws events enable-rule --name coldstart-python36-dev-hourly-burst --profile $1 &
    aws events enable-rule --name coldstart-node810-dev-hourly-burst --profile $1 &
    aws events enable-rule --name coldstart-java8-dev-hourly-burst --profile $1 &
    aws events enable-rule --name coldstart-go-dev-hourly-burst --profile $1 &
    aws events enable-rule --name coldstart-dotnet21-dev-hourly-burst --profile $1 &
fi