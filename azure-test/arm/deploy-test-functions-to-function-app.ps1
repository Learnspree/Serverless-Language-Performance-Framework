# Example usage:
# [pwsh] ./deploy-test-functions.ps1 -runtime "dotnet" -region "East US" -sourcepath "./azure-test/azure-service-dotnet"

# Note - param() must be the first statement in the script
param(
    [Parameter(Mandatory=$True)]
    [string]$runtime,
    
    [Parameter(Mandatory=$True)]
    [string]$region,

    [Parameter(Mandatory=$True)]
    [string]$teststate,
    
    [Parameter(Mandatory=$True)]
    [string]$sourcepath
) 

# Zip the package
$regionLowercase = "${region}".ToLower().Replace(' ', '-')
$zippath = "./azure-$runtime-test${teststate}-$regionLowercase.zip"
Compress-Archive -Path $sourcepath -DestinationPath $zippath -Force

# Deploy the functions
$namePrefix = "spf-azure-test${teststate}";
$rgName = "${namePrefix}-${runtime}-${regionLowercase}-rg"
$appName = "${namePrefix}-${runtime}-${regionLowercase}"

Publish-AzWebapp -ResourceGroupName $rgName -Name $appName -ArchivePath $zippath -Force
