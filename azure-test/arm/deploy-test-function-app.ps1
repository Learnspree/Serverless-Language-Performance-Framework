# Example usage:
# [pwsh] ./deploy-test-function-app.ps1 -runtime "python" -region "East US" -teststate "cold/warm/all" [-runtimeVersion <version> e.g. 10 for node10] 
# Note - param() must be the first statement in the script
param(
    [Parameter(Mandatory=$True)]
    [string]$runtime,
    
    [Parameter(Mandatory=$True)]
    [string]$region,

    [Parameter(Mandatory=$True)]
    [string]$teststate,

    [Parameter(Mandatory=$False)]
    [string]$runtimeVersion
) 

# Register Resource Providers if they're not already registered
Register-AzResourceProvider -ProviderNamespace "microsoft.web"
Register-AzResourceProvider -ProviderNamespace "microsoft.storage"

# create lowercase version of region with hyphens instead of spaces to help with resource naming
$regionLowercase = "${region}".ToLower().Replace(' ', '-')

# Create a resource group for the function app
$namePrefix = "spf-azure-test${teststate}";
$rgName = "${namePrefix}-${runtime}-${regionLowercase}-rg"
$appName = "${namePrefix}-${runtime}-${regionLowercase}"
New-AzResourceGroup -Name $rgName -Location "${region}" -Force

# Create the parameters for the file
if ($runtime -eq "node") {
    $TemplateParams = @{"appName" = "${appName}"; "runtime" = "${runtime}"; "nodeVersion" = "~${runtimeVersion}"}
}
else {
    $TemplateParams = @{"appName" = "${appName}"; "runtime" = "${runtime}"}
}


# Deploy the template
New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile "azure-test-function-deploy.json" -TemplateParameterObject $TemplateParams -Verbose -Force

# Setup continuous export to logger storage account for metrics delivery
$loggerstoragecontainername = "perfmetrics"
$loggerstorageaccount = "spfazuremetricsstorage"
$loggerrg = "spf-azure-logger-east-us-rg"
$subid = (Get-AzSubscription).Id
$storConnectionString = (Get-AzResourceGroupDeployment -ResourceGroupName spf-azure-logger-east-us-rg).Outputs.loggerStorageConnectionString.value
$storagecontext = New-AzStorageContext -ConnectionString $storConnectionString

# generate access token for logger storage account
$sastoken = New-AzStorageContainerSASToken -Name $loggerstoragecontainername -Context $storagecontext -ExpiryTime (Get-Date).AddYears(50) -Permission w
$sasuri = "https://${loggerstorageaccount}.blob.core.windows.net/${loggerstoragecontainername}" + $sastoken

# Create the continous export to logger's storage
New-AzApplicationInsightsContinuousExport -ResourceGroupName $rgName -Name $appName -DocumentType "Request" -StorageAccountId "/subscriptions/{$subid}/resourceGroups/{$loggerrg}/providers/Microsoft.Storage/storageAccounts/${loggerstorageaccount}" -StorageLocation $appName -StorageSASUri $sasuri 