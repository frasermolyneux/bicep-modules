targetScope = 'resourceGroup'

// Parameters
param parLocation string
param parEnvironment string
param parWorkloadName string
param parKeyVaultName string
param parTags object

// Existing Out-Of-Scope Resources
resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: parKeyVaultName
}

// Module Resources
resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: 'sa${parWorkloadName}${parEnvironment}'
  location: parLocation
  kind: 'StorageV2'
  tags: parTags

  sku: {
    name: 'Standard_LRS'
  }
}

// Outputs
output outStorageAccountName string = storageAccount.name
