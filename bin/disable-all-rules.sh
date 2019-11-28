if [ $# -eq 0 ]
  then
    echo "No arguments supplied - using default aws cli profile"
    aws events disable-rule --name warmstart-node810-dev-minute 
    aws events disable-rule --name warmstart-java8-dev-minute 
    aws events disable-rule --name warmstart-dotnet2-dev-minute
    aws events disable-rule --name warmstart-python3-dev-minute
    aws events disable-rule --name warmstart-golang-dev-minute
    aws events disable-rule --name coldstart-python36-dev-hourly-burst
    aws events disable-rule --name coldstart-node810-dev-hourly-burst
    aws events disable-rule --name coldstart-java8-dev-hourly-burst
    aws events disable-rule --name coldstart-go-dev-hourly-burst
    aws events disable-rule --name coldstart-dotnet2-dev-hourly-burst
  else
    echo "Using aws cli profile '$1'"
    aws events disable-rule --name warmstart-node810-dev-minute --profile $1 &
    aws events disable-rule --name warmstart-java8-dev-minute --profile $1 &
    aws events disable-rule --name warmstart-dotnet2-dev-minute --profile $1 &
    aws events disable-rule --name warmstart-python3-dev-minute --profile $1 &
    aws events disable-rule --name warmstart-golang-dev-minute --profile $1 &
    aws events disable-rule --name coldstart-python36-dev-hourly-burst --profile $1 &
    aws events disable-rule --name coldstart-node810-dev-hourly-burst --profile $1 &
    aws events disable-rule --name coldstart-java8-dev-hourly-burst --profile $1 &
    aws events disable-rule --name coldstart-go-dev-hourly-burst --profile $1 &
    aws events disable-rule --name coldstart-dotnet2-dev-hourly-burst --profile $1 &
fi