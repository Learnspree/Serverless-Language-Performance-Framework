echo "***** SPF: running full PRODUCTION build script *****"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "***** SPF: running in $DIR *****"

# build spf-api first (logger depends on this stack's output)
echo "***** SPF: Build API *****"
cd $DIR/spf-api
./spf-build-api-prod.sh

# Build the test functions next (logger depends on this stack's log groups)
echo "***** SPF: Build Test Functions *****"
cd $DIR/aws-test
./spf-build-aws-test-prod.sh

# Finally build the logger which takes test function log entries and delivers to the spf-api
echo "***** SPF: Build Logger Handlers *****"
cd $DIR/aws-common/nodejs-perf-logger
./spf-build-aws-logger-prod.sh

echo "***** SPF: Finished PRODUCTION Build *****"
