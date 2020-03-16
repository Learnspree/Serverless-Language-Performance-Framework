# Example usage:
# [pwsh] ./deploy-logger-function-app.ps1 -region "East US"
# Note - param() must be the first statement in the script
param(
[Parameter(Mandatory=$True)]
    [string]$region
) 

# Register Resource Providers if they're not already registered
Register-AzResourceProvider -ProviderNamespace "microsoft.web"
Register-AzResourceProvider -ProviderNamespace "microsoft.storage"

# create lowercase version of region with hyphens instead of spaces to help with resource naming
$regionLowercase = "${region}".ToLower().Replace(' ', '-')

# Create a resource group for the function app
New-AzResourceGroup -Name "spf-azure-logger-${regionLowercase}-rg" -Location "${region}" -Force

# Create the parameters for the file
$TemplateParams = @{"appName" = "spf-azure-logger-${regionLowercase}"}

# Deploy the template
New-AzResourceGroupDeployment -ResourceGroupName "spf-azure-logger-${regionLowercase}-rg" -TemplateFile "azure-logger-function-deploy.json" -TemplateParameterObject $TemplateParams -Verbose -Force