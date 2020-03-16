# Example usage:
# [pwsh] ./deploy-logger-function-app.ps1 -region "East US"
# Note - param() must be the first statement in the script
param(
[Parameter(Mandatory=$True)]
    [string]$region
) 

# Register Resource Providers if they're not already registered 
# Commenting out - NOT NEEDED HERE??
#Register-AzResourceProvider -ProviderNamespace "microsoft.web"
#Register-AzResourceProvider -ProviderNamespace "microsoft.storage"

# create lowercase version of region with hyphens instead of spaces to help with resource naming
$regionLowercase = "${region}".ToLower().Replace(' ', '-')
$rgName = "spf-azure-logger-${regionLowercase}-rg"

# Create a resource group for the function app
New-AzResourceGroup -Name $rgName -Location "${region}" -Force

# Create the parameters for the file
$TemplateParams = @{"appName" = "spf-azure-logger-${regionLowercase}"}

# Deploy the function app ARM template
New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile "azure-logger-function-deploy.json" -TemplateParameterObject $TemplateParams -Verbose -Force

# Zip the logger function package
$zippath = "./azure-logger-$regionLowercase.zip"
Compress-Archive -Path ../azure-logger/* -DestinationPath $zippath -Force

# Deploy the function
$appName = "spf-azure-logger-${regionLowercase}"
Publish-AzWebapp -ResourceGroupName $rgName -Name $appName -ArchivePath $zippath -Force