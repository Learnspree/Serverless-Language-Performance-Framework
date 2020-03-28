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
    [string]$environment = "dev",

    [Parameter(Mandatory=$False)]
    [string]$runtimeVersion = "x"
) 

# include helper
. ./resource-name-helper.ps1

# set folder for zipping - default to the actual source folder (e.g. azure-test/azure-service-coldstart-node)
$deploymentSourcePath = $sourcepath

# For node, setup function name to be deployed by setting the folder name containing the function being deployed
# then we'll zip it up. This is done so that we can re-use the azure-service-node function for multiple node runtime versions
# and to match the runtime name to the same name set by AWS testing for node (e.g. nodejs12x, nodejs10x)
if ($runtime -eq "node") {
    $deploymentSourcePath = "./deploymentSourcePath"
    Copy-Item -Path $sourcepath -Recurse -Destination "${deploymentSourcePath}"
    Get-ChildItem -Path $deploymentSourcePath "azure-*-${runtime}" | Rename-Item -NewName { $_.Name -replace "${runtime}","nodejs${runtimeVersion}x" }
}

# Zip the package
$regionLowercase = getLowercaseRegionName "${region}"
$zippath = "./azure-${runtime}${runtimeVersion}-test-${teststate}-${regionLowercase}-${environment}.zip"
Compress-Archive -Path "${deploymentSourcePath}/*" -DestinationPath $zippath -Force

# Deploy the functions
$rgName = buildResourceGroupName "${teststate}" "${runtime}" "${runtimeVersion}" "${region}" "${environment}"
$appName = buildFunctionAppName "${teststate}" "${runtime}" "${runtimeVersion}" "${region}" "${environment}"
Publish-AzWebapp -ResourceGroupName $rgName -Name $appName -ArchivePath $zippath -Force

# cleanup - zip file
Remove-Item -Force $zippath

# cleanup - delete temporary folder that was created for function naming
if ($runtime -eq "node") {
    Remove-Item -Recurse -Force $deploymentSourcePath
}
