# Example usage:
# [pwsh] ./login-with-service-principal.ps1 -servicePrincipalPass "<password>"

# Note - param() must be the first statement in the script
param([string]$servicePrincipalPass) 

# Setup credentials
$securepassword = ConvertTo-SecureString -String $servicePrincipalPass -AsPlainText -Force
$principalName = "http://SPFDeploymentServicePrincipal"
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $principalName, $securepassword

# Connect to the Azure Account
$tenantId = (Get-AzContext).Tenant.Id
$subscriptionId = (Get-AzSubscription).Id
Connect-AzAccount -ServicePrincipal -Credential $credentials -Tenant $tenantId -Subscription $subscriptionId
