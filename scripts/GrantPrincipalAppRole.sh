#!/bin/bash

principalId=$1
serverApplicationName=$2
roleName=${3:-ServiceAccount}

serverApplicationId=$(az ad app list --filter "displayName eq '$serverApplicationName'" --query '[].appId' | jq -r '.[]')
serverResourceId=$(az ad sp list --filter "appId eq '$serverApplicationId'" --query '[0].id' | jq -r '.')
serverApiSpn=$(az rest -m GET -u https://graph.microsoft.com/v1.0/servicePrincipals/$serverResourceId | jq -r '.')
serverAppRoleId=$(echo $serverApiSpn | jq -r --arg roleName "$roleName" '.appRoles[] | select(.displayName == $roleName) | .id')

permissions=$(az rest -m GET -u https://graph.microsoft.com/v1.0/servicePrincipals/$principalId/appRoleAssignments | jq -r '.')
if [[ -z $(echo $permissions | jq -r --arg serverAppRoleId "$serverAppRoleId" '.value[] | select(.appRoleId == $serverAppRoleId)') ]]; then
    az rest -m POST -u https://graph.microsoft.com/v1.0/servicePrincipals/$principalId/appRoleAssignments -b "{'principalId': '$principalId', 'resourceId': '$serverResourceId','appRoleId': '$serverAppRoleId'}"
fi