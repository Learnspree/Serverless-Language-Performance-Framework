# Example usage:
# [pwsh] ./deploy-test-functions.ps1 -runtime "dotnet" -region "East US" -sourcepath "./azure-test/azure-service-csharp"

# Note - param() must be the first statement in the script
param([string]$runtime="node",[string]$region="East US",[string]$sourcepath) 

# Zip the package
$regionLowercase = "${region}".ToLower().Replace(' ', '-')
$zippath = "./azure-$runtime-test-$regionLowercase.zip"
Compress-Archive -Path $sourcepath -DestinationPath $zippath

# Deploy the functions
$appName = "spf-azure-test-${runtime}-${regionLowercase}-rg"

Publish-AzWebapp -ResourceGroupName $appName -Name $appName -ArchivePath $zippath
