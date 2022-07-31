targetScope = 'resourceGroup'

// Parameters
param parKeyVaultName string
param parSecretName string
@secure()
param parSecretValue string
param parTags object

// Existing In-Scope Resources
resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: parKeyVaultName
}

// Module Resources
resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: parSecretName
  parent: keyVault
  tags: parTags

  properties: {
    contentType: 'text/plain'
    value: parSecretValue
  }
}
