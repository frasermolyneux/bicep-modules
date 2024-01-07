#!/bin/bash

keyVaultName=$1
applicationName=$2
secretPrefix=$3
secretDisplayName=$4

applicationId=$(az ad app list --filter "displayName eq '$applicationName'" --query '[].appId' | jq -r '.[]')
credentials=$(az ad app credential list --id "$applicationId" | jq -r '.')

if [ -z "$(az keyvault secret show --vault-name "$keyVaultName" --name "$secretPrefix-client-id")" ]; then
    echo "Creating client id secret with name '$secretPrefix-client-id' in '$keyVaultName'"
    az keyvault secret set --name "$secretPrefix-client-id" --vault-name "$keyVaultName" --value "$applicationId" --description 'text/plain' --output none
fi

secrets=$(az keyvault secret list --vault-name $keyVaultName | jq -r '.')
if [ "$(echo $secrets | jq -r "map(select(.name | test(\"$secretPrefix-client-secret\"))) | length")" -eq 0 ]; then
    if [ "$(echo $credentials | jq -r 'length')" -ne 0 ]; then
        echo "No credentials in Key Vault with name '$secretPrefix-client-secret' in '$keyVaultName' but app has credentials - assuming reset"
        for row in $(echo "${credentials}" | jq -r '.[] | @base64'); do
            _jq() {
                echo ${row} | base64 --decode | jq -r ${1}
            }
            az ad app credential delete --id "$applicationId" --key-id $(_jq '.keyId')
        done
        credentials=$(az ad app credential list --id "$applicationId" | jq -r '.')
    fi
fi

if [ "$(echo $credentials | jq -r 'length')" -eq 0 ]; then
    echo "No credentials: Creating credential and storing in Key Vault with name '$secretPrefix-client-secret' in '$keyVaultName'"
    credential=$(az ad app credential reset --id "$applicationId"  --append --years 2 --display-name "$secretDisplayName" | jq -r '.')
    az keyvault secret set --name "$secretPrefix-client-secret" --vault-name "$keyVaultName" --value $credential.password --description 'text/plain' --output none
fi

if [ "$(echo $credentials | jq -r 'length')" -eq 1 ]; then
    echo "Single credential: Creating credential and storing in Key Vault with name '$secretPrefix-client-secret' in '$keyVaultName'"
    credential=$(az ad app credential reset --id "$applicationId"  --append --years 1 --display-name "$secretDisplayName" | jq -r '.')
    az keyvault secret set --name "$secretPrefix-client-secret" --vault-name "$keyVaultName" --value $credential.password --description 'text/plain' --output none
fi

if [ "$(echo $credentials | jq -r 'length')" -eq 2 ]; then
    echo "Multiple credential: Checking to see if we need to rotate the secret"

    for row in $(echo "${credentials}" | jq -r '.[] | @base64'); do
        _jq() {
            echo ${row} | base64 --decode | jq -r ${1}
        }
        echo "Credential expires in '$(_jq '.endDateTime')"
    done

    credentialToDelete=$(echo $credentials | jq -r 'sort_by(.endDateTime) | .[0]')
    expiryDate=$(date -d $(echo $credentialToDelete | jq -r '.endDateTime') +%s)

    if [ $expiryDate -lt $(date -d "+3 months" +%s) ]; then
        echo "Near Expiry Credential: Reset credential with expiry '$(echo $credentialToDelete | jq -r '.endDateTime')' and store in Key Vault with name '$secretPrefix-client-secret' in '$keyVaultName'"

        az ad app credential delete --id "$applicationId" --key-id $(echo $credentialToDelete | jq -r '.keyId')

        credential=$(az ad app credential reset --id "$applicationId"  --append --years 1 --display-name "$secretDisplayName" | jq -r '.')
        az keyvault secret set --name "$secretPrefix-client-secret" --vault-name "$keyVaultName" --value $(echo $credential | jq -r '.password') --description 'text/plain' --output none
    else
        echo "No credentials are near expiry - doing nothing"
    fi
fi