targetScope = 'resourceGroup'

// Parameters
@description('The app configuration store name')
param appConfigurationStoreName string

@description('The app configuration sku')
param appConfigurationStoreSku string = 'free'

@description('The location of the resources.')
param location string = resourceGroup().location

@description('The tags to apply to the resources.')
param tags object

// Module Resources
resource configurationStore 'Microsoft.AppConfiguration/configurationStores@2022-05-01' = {
  name: appConfigurationStoreName
  location: location

  tags: tags

  sku: {
    name: appConfigurationStoreSku
  }

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    disableLocalAuth: false
    enablePurgeProtection: true
    encryption: {}
    softDeleteRetentionInDays: 30
  }
}

// Outputs
output appConfigurationStoreRef object = {
  Name: configurationStore.name
  SubscriptionId: subscription().subscriptionId
  ResourceGroupName: resourceGroup().name
}
