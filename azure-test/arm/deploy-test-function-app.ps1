# Example usage:
# [pwsh] ./deploy-test-function-app.ps1 -runtime "python" -region "East US"
# Note - param() must be the first statement in the script
param([string]$runtime="node",[string]$region="East US") 

# Register Resource Providers if they're not already registered
Register-AzResourceProvider -ProviderNamespace "microsoft.web"
Register-AzResourceProvider -ProviderNamespace "microsoft.storage"

# create lowercase version of region with hyphens instead of spaces to help with resource naming
$regionLowercase = "${region}".ToLower().Replace(' ', '-')

# Create a resource group for the function app
New-AzResourceGroup -Name "spf-azure-test-${runtime}-${regionLowercase}-rg" -Location "${region}" -Force

# Create the parameters for the file
$TemplateParams = @{"appName" = "spf-azure-test-${runtime}-${regionLowercase}"; "runtime" = "${runtime}"}

# Deploy the template
New-AzResourceGroupDeployment -ResourceGroupName "spf-azure-test-${runtime}-${regionLowercase}-rg" -TemplateFile "azure-test-function-deploy.json" -TemplateParameterObject $TemplateParams -Verbose -Force