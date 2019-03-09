echo "***** SPF: running build script *****"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "***** SPF: running in $DIR *****"

npm install request # just a one-off command - don't need to do this every build
serverless package --package aws-artifacts 

echo "***** SPF: finished build stage *****"

echo "***** SPF: running sls deploy stage *****"

serverless deploy --package aws-artifacts/ 

echo "***** SPF: finished sls deploy stage *****"