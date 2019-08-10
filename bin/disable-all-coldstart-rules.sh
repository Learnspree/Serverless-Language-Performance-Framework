if [ $# -eq 0 ]
  then
    echo "No arguments supplied - using default aws cli profile"
    aws events disable-rule --name coldstart-node810-hourly
    aws events disable-rule --name coldstart-java8-hourly
    aws events disable-rule --name coldstart-dotnet2-hourly
    aws events disable-rule --name coldstart-python3-hourly
    aws events disable-rule --name coldstart-golang-hourly
  else
    echo "Using aws cli profile '$1'"
    aws events disable-rule --name coldstart-node810-hourly --profile $1 &
    aws events disable-rule --name coldstart-java8-hourly --profile $1 &
    aws events disable-rule --name coldstart-dotnet2-hourly --profile $1 &
    aws events disable-rule --name coldstart-python3-hourly --profile $1 &
    aws events disable-rule --name coldstart-golang-hourly --profile $1 &
fi

