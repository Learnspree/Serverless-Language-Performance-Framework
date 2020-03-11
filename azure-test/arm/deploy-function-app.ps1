# Connect to the Azure Account
## Run 'pwsh' from macos terminal to start powershell
## Run 'Connect-AzAccount' before running this script for now (will setup a service principal in future)

# Register Resource Providers if they're not already registered
Register-AzResourceProvider -ProviderNamespace "microsoft.web"
Register-AzResourceProvider -ProviderNamespace "microsoft.storage"

# Create a resource group for the function app
New-AzResourceGroup -Name "test-spf-app-rg" -Location 'East US' -Force

# Create the parameters for the file, which for this template is the function app name.
$TemplateParams = @{"appName" = "test-spf-app"}

# Deploy the template
New-AzResourceGroupDeployment -ResourceGroupName "test-spf-app-rg" -TemplateFile "azure-test-function-deploy.json" -TemplateParameterObject $TemplateParams -Verbose -Force