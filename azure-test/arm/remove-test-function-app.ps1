# Example usage:
# [pwsh] ./remove-test-function-app.ps1 -runtime "python" -region "East US" -teststate "cold/warm"
# Note - param() must be the first statement in the script
param(
    [Parameter(Mandatory=$True)]
    [string]$runtime,
    
    [Parameter(Mandatory=$True)]
    [string]$region,

    [Parameter(Mandatory=$True)]
    [string]$teststate,

    [Parameter(Mandatory=$False)]
    [string]$environment = "dev",

    [Parameter(Mandatory=$False)]
    [string]$runtimeVersion = "x"
) 

# include helper
. ./resource-name-helper.ps1

# delete the resource group
$rgName = buildResourceGroupName "${teststate}" "${runtime}" "${runtimeVersion}" "${region}" "${environment}"
Remove-AzResourceGroup -Name "${rgName}" -Force
