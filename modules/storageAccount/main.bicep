targetScope = 'resourceGroup'

// Parameters
@description('The environment for the storage account')
param environment string

@description('The workload the storage account is for')
param workload string

@description('The storage account sku for the storage account')
param sku string = 'Standard_LRS'

@description('The location to deploy the storage account in')
param location string = resourceGroup().location

@description('The tags to be applied to the storage account')
param tags object

// Module Resources
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'sa${uniqueString(resourceGroup().id, workload, environment)}'
  location: location
  kind: 'StorageV2'
  tags: tags

  sku: {
    name: sku
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
