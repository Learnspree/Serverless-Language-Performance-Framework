# Example usage:
# [pwsh] ./remove-test-function-app.ps1 -runtime "python" -region "East US"

# Connect to the Azure Account
## Run 'Connect-AzAccount' before running this script for now (will setup a service principal in future)

# Note - param() must be the first statement in the script
param([string]$runtime="node",[string]$region="East US") 

# create lowercase version of region with hyphens instead of spaces to help with resource naming
$regionLowercase = "${region}".ToLower().Replace(' ', '-')

# Create a resource group for the function app
Remove-AzResourceGroup -Name "spf-azure-test-${runtime}-${regionLowercase}-rg" -Force
