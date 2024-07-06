targetScope = 'resourceGroup'

// Parameters
@description('The storage account name')
param storageAccountName string = ''

@description('The environment for the resources')
param environment string = ''

@description('The workload the storage account is for (must set if not providing storageAccountName)')
param workload string = ''

@description('The storage account sku for the storage account')
param sku string = 'Standard_LRS'

@description('The location to deploy the resources')
param location string = resourceGroup().location

@description('The tags to apply to the resources')
param tags object

// Module Resources
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: !empty(storageAccountName) ? storageAccountName : 'sa${uniqueString(resourceGroup().id, workload, environment)}'
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
