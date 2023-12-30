#!/bin/bash

clientId=$1
clientSecret=$2
tenantId=$3
applicationName=$4
appRoles=$5

az login --service-principal -u "$clientId" -p "$clientSecret" --tenant "$tenantId"

az ad app create --display-name "$applicationName" --identifier-uris "api://$applicationName" > /dev/null
applicationId=$(az ad app list --filter "displayName eq '$applicationName'" --query '[].appId' | jq -r '.[]')
objectId=$(az ad app list --filter "displayName eq '$applicationName'" --query '[].id' | jq -r '.[]')

az ad app update --id "$applicationId" --sign-in-audience 'AzureADMyOrg' --enable-id-token-issuance true --enable-access-token-issuance false > /dev/null
az rest --method PATCH --uri "https://graph.microsoft.com/v1.0/applications/$objectId" --headers 'Content-Type=application/json' --body '{"api":{"requestedAccessTokenVersion":1}}'

applicationServicePrincipal=$(az ad sp show --id "$applicationId")
if [ -z "$applicationServicePrincipal" ]
then
    az ad sp create --id "$applicationId" > /dev/null
fi

if [ ! -z "$appRoles" ]
then
    az ad app update --id "$applicationId" --app-roles "app-registration-manifests/$appRoles" > /dev/null
fi