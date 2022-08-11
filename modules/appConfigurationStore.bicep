targetScope = 'resourceGroup'

// Parameters
param parAppConfigurationStoreName string
param parLocation string

param parAppConfigurationStoreSku string = 'free'

param parTags object

// Module Resources
resource configurationStore 'Microsoft.AppConfiguration/configurationStores@2022-05-01' = {
  name: parAppConfigurationStoreName
  location: parLocation

  tags: parTags

  sku: {
    name: parAppConfigurationStoreSku
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
