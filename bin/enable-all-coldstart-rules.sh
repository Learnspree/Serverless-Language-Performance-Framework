if [ $# -eq 0 ]
  then
    echo "No arguments supplied - using default aws cli profile"
    aws events enable-rule --name coldstart-python36-hourly-burst
    aws events enable-rule --name coldstart-node810-hourly-burst
    aws events enable-rule --name coldstart-java8-hourly-burst
    aws events enable-rule --name coldstart-go-hourly-burst
    aws events enable-rule --name coldstart-dotnet2-hourly-burst
  else
    echo "Using aws cli profile '$1'"
    aws events enable-rule --name coldstart-python36-hourly-burst --profile $1 &
    aws events enable-rule --name coldstart-node810-hourly-burst --profile $1 &
    aws events enable-rule --name coldstart-java8-hourly-burst --profile $1 &
    aws events enable-rule --name coldstart-go-hourly-burst --profile $1 &
    aws events enable-rule --name coldstart-dotnet2-hourly-burst --profile $1 &
fi