echo "***** SPF: running cleanup script PRODUCTION *****"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "***** SPF: running in $DIR *****"
cd $DIR
# serverless framework will remove the cloud-formation stack
serverless remove -v --stage prod
echo "***** SPF: finished cleanup script PRODUCTION *****"