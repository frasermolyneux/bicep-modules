targetScope = 'resourceGroup'

// Parameters
@description('The storage account environment')
param environment string

@description('The storage account workload')
param workload string

@description('The location of the resources.')
param location string = resourceGroup().location

@description('The tags to apply to the resources.')
param tags object

// Module Resources
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'sa${uniqueString(resourceGroup().id, workload, environment)}'
  location: location
  kind: 'StorageV2'
  tags: tags

  sku: {
    name: 'Standard_LRS'
  }

  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
}

// Outputs
output storageAccountRef object = {
  subscriptionId: subscription().subscriptionId
  resourceGroupName: resourceGroup().name
  name: storageAccount.name
  id: storageAccount.id
}
