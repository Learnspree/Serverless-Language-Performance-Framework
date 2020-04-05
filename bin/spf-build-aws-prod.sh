echo "***** SPF: running full PRODUCTION build script *****"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "***** SPF: running in $DIR *****"

# build spf-api first (logger depends on this stack's output)
echo "***** SPF: Build API *****"
cd $DIR/../spf-api
./spf-build-api.sh -e prod -d "api.serverlessperformance.net" -b &

# Build the test functions next (logger depends on this stack's log groups)
echo "***** SPF: Build Test Functions *****"
cd $DIR/../aws-test
./spf-build-aws-test.sh -e prod -t

# Finally build the logger which takes test function log entries and delivers to the spf-api
echo "***** SPF: Build Logger Handlers *****"
cd $DIR/../aws-common
./spf-build-aws-logger-prod.sh

echo "***** SPF: Finished PRODUCTION Build *****"
