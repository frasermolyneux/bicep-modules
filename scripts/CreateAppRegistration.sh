#!/bin/bash

applicationName=$1
appRoles=$2

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
    az ad app update --id "$applicationId" --app-roles "$(jq -r $appRoles)" > /dev/null
fi
