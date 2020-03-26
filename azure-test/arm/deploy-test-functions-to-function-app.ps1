# Example usage:
# [pwsh] ./deploy-test-functions-to-function-app.ps1 -runtime "dotnet" -region "East US" -sourcepath "./azure-test/azure-service-dotnet" [-runtimeVersion "10"]

# Note - param() must be the first statement in the script
param(
    [Parameter(Mandatory=$True)]
    [string]$runtime,
    
    [Parameter(Mandatory=$True)]
    [string]$region,

    [Parameter(Mandatory=$True)]
    [string]$teststate,
    
    [Parameter(Mandatory=$True)]
    [string]$sourcepath,

    [Parameter(Mandatory=$False)]
    [string]$runtimeVersion
) 

# setup function name via the folder name for the function being deployed
$deploymentSourcePath = $sourcepath
if ($runtime -eq "node") {
    $deploymentSourcePath = "./deploymentSourcePath"
    Copy-Item -Path $sourcepath -Recurse -Destination "${deploymentSourcePath}"
    Get-ChildItem -Path $deploymentSourcePath azure-*-node | Rename-Item -NewName { $_.Name -replace 'node',"nodejs${runtimeVersion}x" }
}

# Zip the package
$regionLowercase = "${region}".ToLower().Replace(' ', '-')
$zippath = "./azure-${runtime}${runtimeVersion}-test${teststate}-${regionLowercase}.zip"
Compress-Archive -Path "${deploymentSourcePath}/*" -DestinationPath $zippath -Force

# Deploy the functions
$namePrefix = "spf-azure-test${teststate}";
$rgName = "${namePrefix}-${runtime}-${regionLowercase}-rg"
$appName = "${namePrefix}-${runtime}-${regionLowercase}"

Publish-AzWebapp -ResourceGroupName $rgName -Name $appName -ArchivePath $zippath -Force

# cleanup - zip file
Remove-Item -Force $zippath

# cleanup - delete temporary folder that was created for function naming
if ($runtime -eq "node") {
    Remove-Item -Recurse -Force $deploymentSourcePath
}
