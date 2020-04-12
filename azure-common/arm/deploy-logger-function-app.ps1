# Example usage:
# [pwsh] ./deploy-logger-function-app.ps1 -region "East US" [-environment "dev"] [-spfdomain "my-spf-api-domain.example.com"]
# Note - param() must be the first statement in the script
param(
    [Parameter(Mandatory=$True)]
    [string]$region,

    [Parameter(Mandatory=$False)]
    [string]$spfdomain = "dummy.mydomain.net",

    [Parameter(Mandatory=$False)]
    [string]$environment = "dev"
) 

# create lowercase version of region with hyphens instead of spaces to help with resource naming
$regionLowercase = "${region}".ToLower().Replace(' ', '-')
$rgName = "spf-azure-logger-${regionLowercase}-${environment}-rg"

# Create a resource group for the function app
New-AzResourceGroup -Name $rgName -Location "${region}" -Force

# Create the parameters for the file
$appName = "spf-azure-logger-${regionLowercase}-${environment}"
$TemplateParams = @{"appName" = "${appName}"; "spfenvironment" = "${environment}"; "spfdomain" = "${spfdomain}"}

# Deploy the function app ARM template
New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile "azure-logger-function-deploy.json" -TemplateParameterObject $TemplateParams -Verbose -Force

# Zip the logger function package
$zippath = "./azure-logger-$regionLowercase-${environment}.zip"
Compress-Archive -Path ../azure-logger/* -DestinationPath $zippath -Force

# Deploy the function
Publish-AzWebapp -ResourceGroupName $rgName -Name $appName -ArchivePath $zippath -Force