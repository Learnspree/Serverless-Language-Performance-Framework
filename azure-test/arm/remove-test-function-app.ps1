# Example usage:
# [pwsh] ./remove-test-function-app.ps1 -runtime "python" -region "East US"
# Note - param() must be the first statement in the script
param([string]$runtime="node",[string]$region="East US") 

# create lowercase version of region with hyphens instead of spaces to help with resource naming
$regionLowercase = "${region}".ToLower().Replace(' ', '-')

# Create a resource group for the function app
Remove-AzResourceGroup -Name "spf-azure-test-${runtime}-${regionLowercase}-rg" -Force
