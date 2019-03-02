echo "***** SPF: running build script *****"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "***** SPF: running in $DIR *****"

# build java8 test function
cd $DIR/aws-service-java8
mvn clean install 

# Build the .net core 2 test function
cd $DIR/aws-service-dotnetcore2
./build-macos.sh  # Different scripts exist for Windows or Linux

# For the golang test function
cd $DIR/aws-service-go
make

echo "***** SPF: finished build stage *****"

echo "***** SPF: running sls deploy stage *****"

cd $DIR
serverless deploy -v

echo "***** SPF: finished sls deploy stage *****"