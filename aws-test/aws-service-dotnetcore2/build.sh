#!/bin/bash

#install zip
apt-get -qq update
apt-get -qq -y install zip

dotnet restore

#create deployment package
dotnet lambda package --configuration release --framework netcoreapp2.1 --output-package bin/release/netcoreapp2.1/deploy-package.zip
