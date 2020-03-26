# Example usage:
# [pwsh] ./remove-test-function-app.ps1 -runtime "python" -region "East US" -teststate "cold/warm"
# Note - param() must be the first statement in the script
param(
    [Parameter(Mandatory=$True)]
    [string]$runtime,
    
    [Parameter(Mandatory=$True)]
    [string]$region,

    [Parameter(Mandatory=$True)]
    [string]$teststate
) 

# create lowercase version of region with hyphens instead of spaces to help with resource naming
$regionLowercase = "${region}".ToLower().Replace(' ', '-')

# Create a resource group for the function app
$namePrefix = "spf-azure-test${teststate}";
$rgName = "${namePrefix}-${runtime}-${regionLowercase}-rg"
Remove-AzResourceGroup -Name "${rgName}" -Force
