# Connect to the Azure Account
## Run 'pwsh' from macos terminal to start powershell
## Run 'Connect-AzAccount' before running this script for now (will setup a service principal in future)

$runtime = "node"
$region = "East US"
$regionLowercase = "east-us"

# Register Resource Providers if they're not already registered
Register-AzResourceProvider -ProviderNamespace "microsoft.web"
Register-AzResourceProvider -ProviderNamespace "microsoft.storage"

# Create a resource group for the function app
New-AzResourceGroup -Name "spf-azure-test-${runtime}-${regionLowercase}-rg" -Location "${region}" -Force

# Create the parameters for the file
$TemplateParams = @{"appName" = "spf-azure-test-${runtime}-${regionLowercase}"; "runtime" = "${runtime}"}

# Deploy the template
New-AzResourceGroupDeployment -ResourceGroupName "spf-azure-test-${runtime}-${regionLowercase}-rg" -TemplateFile "azure-test-function-deploy.json" -TemplateParameterObject $TemplateParams -Verbose -Force