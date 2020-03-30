# Example usage:
# [pwsh] ./remove-logger-function-app.ps1 -region "East US" -environment "dev"
# Note - param() must be the first statement in the script
param(
    [Parameter(Mandatory=$True)]
    [string]$region,

    [Parameter(Mandatory=$False)]
    [string]$environment = "dev"
) 

# delete the resource group
$regionLowercase = "${region}".ToLower().Replace(' ', '-')
$rgName = "spf-azure-logger-${regionLowercase}-${environment}-rg"
Remove-AzResourceGroup -Name "${rgName}" -Force
