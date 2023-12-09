targetScope = 'resourceGroup'

// Parameters
param parLocation string
param parEnvironment string

param parWorkloadName string

param parTags object

// Module Resources
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'sa${parWorkloadName}${parEnvironment}'
  location: parLocation
  kind: 'StorageV2'
  tags: parTags

  sku: {
    name: 'Standard_LRS'
  }

  properties: {
    minimumTlsVersion: 'TLS1_2'

    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }

    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
}

// Outputs
output outStorageAccountName string = storageAccount.name
