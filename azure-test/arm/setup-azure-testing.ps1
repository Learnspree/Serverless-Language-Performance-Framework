# Pre-requisite: Run 'Connect-AzAccount' from powershell to login to your subscription
# Example usage: pwsh setup-azure-testing.ps1 -servicePrincipalPass "<password>"

# Note - param() must be the first statement in the script
param([string]$servicePrincipalPass) 

# Import the PSADPasswordCredential object
Import-Module Az.Resources 

# Register Resource Providers if they're not already registered
Register-AzResourceProvider -ProviderNamespace "microsoft.web"
Register-AzResourceProvider -ProviderNamespace "microsoft.storage"

# create credentials for service principal
$credentials = New-Object Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential -Property @{ StartDate=Get-Date; EndDate=Get-Date -Year 2024; Password=$servicePrincipalPass} 

# create service principal
$principalDisplayName = "SPFDeploymentServicePrincipal"
New-AzAdServicePrincipal -DisplayName $principalDisplayName -PasswordCredential $credentials

# create role assignment
$subId = (Get-AzSubscription).Id
$principalObjectId = (Get-AzADServicePrincipal -DisplayName $principalDisplayName).Id
New-AzRoleAssignment -ObjectId $principalObjectId -RoleDefinitionName "Contributor" -Scope "/subscriptions/$subId"

