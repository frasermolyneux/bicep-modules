param (
    $applicationName,
    $appRoles = $null
)

az ad app create --display-name "$applicationName" --identifier-uris "api://$applicationName" | Out-Null
$applicationId = (az ad app list --filter "displayName eq '$applicationName'" --query '[].appId') | ConvertFrom-Json
$objectId = (az ad app list --filter "displayName eq '$applicationName'" --query '[].id') | ConvertFrom-Json

az ad app update --id "$applicationId" --sign-in-audience 'AzureADMyOrg' --enable-id-token-issuance true --enable-access-token-issuance false | Out-Null
az rest --method PATCH --uri "https://graph.microsoft.com/v1.0/applications/$objectId" --headers 'Content-Type=application/json' --body '{\""api\"":{\""requestedAccessTokenVersion\"":1}}'

$applicationServicePrincipal = az ad sp show --id "$applicationId"
if ($null -eq $applicationServicePrincipal) {
    az ad sp create --id "$applicationId" | Out-Null
}

if ($null -ne $appRoles) {
    az ad app update --id "$applicationId" --app-roles "app-registration-manifests/$appRoles" | Out-Null
}
