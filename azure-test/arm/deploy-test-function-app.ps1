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
    [string]$environment = "dev",

    [Parameter(Mandatory=$False)]
    [string]$runtimeVersion = "x"
) 

# include helper
. ./resource-name-helper.ps1

# create resource-group
$rgName = buildResourceGroupName "${teststate}" "${runtime}" "${runtimeVersion}" "${region}" "${environment}"
New-AzResourceGroup -Name $rgName -Location "${region}" -Force

# Deploy the ARM template for the Function App
$appName = buildFunctionAppName "${teststate}" "${runtime}" "${runtimeVersion}" "${region}" "${environment}"
$TemplateParams = buildFunctionAppARMTemplateParameters $appName $runtime $runtimeVersion
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