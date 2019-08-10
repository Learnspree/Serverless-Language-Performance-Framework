if [ $# -eq 0 ]
  then
    echo "No arguments supplied - using default aws cli profile"
    aws events disable-rule --name warmstart-node810-minute 
    aws events disable-rule --name warmstart-java8-minute 
    aws events disable-rule --name warmstart-dotnet2-minute 
    aws events disable-rule --name warmstart-python3-minute 
    aws events disable-rule --name warmstart-golang-minute 

  else
    echo "Using aws cli profile '$1'"
    aws events disable-rule --name warmstart-node810-minute --profile $1 &
    aws events disable-rule --name warmstart-java8-minute --profile $1 &
    aws events disable-rule --name warmstart-dotnet2-minute --profile $1 &
    aws events disable-rule --name warmstart-python3-minute --profile $1 &
    aws events disable-rule --name warmstart-golang-minute --profile $1 &
fi