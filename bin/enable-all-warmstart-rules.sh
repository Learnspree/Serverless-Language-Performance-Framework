if [ $# -eq 0 ]
  then
    echo "No arguments supplied - using default aws cli profile"
    aws events enable-rule --name warmstart-node810-dev-minute
    aws events enable-rule --name warmstart-java8-dev-minute
    aws events enable-rule --name warmstart-dotnet2-dev-minute
    aws events enable-rule --name warmstart-python3-dev-minute
    aws events enable-rule --name warmstart-golang-dev-minute
  else
    echo "Using aws cli profile '$1'"
    aws events enable-rule --name warmstart-node810-dev-minute --profile $1 &
    aws events enable-rule --name warmstart-java8-dev-minute --profile $1 &
    aws events enable-rule --name warmstart-dotnet2-dev-minute --profile $1 &
    aws events enable-rule --name warmstart-python3-dev-minute --profile $1 &
    aws events enable-rule --name warmstart-golang-dev-minute --profile $1 &
fi