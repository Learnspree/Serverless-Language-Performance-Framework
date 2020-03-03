echo "***** SPF: running build script *****"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "***** SPF: running in $DIR *****"

# Build the .net core 2 metrics function
cd $DIR/lambda-metrics-service
dotnet add package AWSSDK.DynamoDBv2 --version 3.3.6
dotnet add package Amazon.Lambda.APIGatewayEvents
./build-macos.sh

echo "***** SPF: finished build stage *****"

echo "***** SPF: start test stage *****"

cd $DIR
python -m unittest discover -v 

echo "***** SPF: finished test stage *****"


echo "***** SPF: running sls deploy stage *****"

cd $DIR

# During serverless deploy, optionally setup custom domain base path mappings to map custom domain 
# (like 'api.serverlessperformance.net') to API Gateway AWS URL
npm install serverless-domain-manager --save-dev
serverless create_domain --stage dev
serverless deploy -v --stage dev

echo "***** SPF: finished sls deploy stage *****"