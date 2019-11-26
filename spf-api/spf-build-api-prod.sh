echo "***** SPF: PRODUCTION running build script *****"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "***** SPF: PRODUCTION running in $DIR *****"

# Build the .net core 2 metrics function
# NOTE - the nodejs cost service (lambda-cost-service) does not require any pre-compilation/build
cd $DIR/lambda-metrics-service
dotnet add package AWSSDK.DynamoDBv2 --version 3.3.6
dotnet add package Amazon.Lambda.APIGatewayEvents
./build-macos.sh

echo "***** SPF: finished build stage PRODUCTION *****"

echo "***** SPF: running sls deploy stage PRODUCTION *****"

cd $DIR
serverless deploy -v --stage prod

echo "***** SPF: finished sls deploy stage PRODUCTION *****"