echo "***** SPF: running full remove script PRODUCTION *****"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "***** SPF: running in $DIR *****"

# Remove the logger which takes test function log entries and delivers to the spf-api
echo "***** SPF: Remove Logger Handlers *****"
cd $DIR/../aws-common/nodejs-perf-logger
./spf-remove-aws-logger-prod.sh

# Remove spf-api next (logger depends on this stack's output)
echo "***** SPF: Remove API *****"
cd $DIR/../spf-api
./spf-remove-api-prod.sh

# Remove the test functions next (logger depends on this stack's log groups)
echo "***** SPF: Remove Test Functions *****"
cd $DIR/../aws-test
./spf-remove-aws-test-prod.sh

echo "***** SPF: Finished Remove PRODUCTION *****"
