targetScope = 'resourceGroup'

// Parameters
@description('The key vault name')
param keyVaultName string

@description('The secret name')
param secretName string

@secure()
@description('The secret value')
param secretValue string

@description('The tags to apply to the resources.')
param tags object

// Resource References
resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

// Module Resources
resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: secretName
  parent: keyVault
  tags: tags

  properties: {
    contentType: 'text/plain'
    value: secretValue
  }
}

// Outputs
output secretRef object = {
  secretName: keyVaultSecret.name
  secretUri: keyVaultSecret.properties.secretUri
  secretUriWithVersion: keyVaultSecret.properties.secretUriWithVersion
}
