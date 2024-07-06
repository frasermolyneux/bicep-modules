targetScope = 'resourceGroup'

// Parameters
@description('The sql server name')
param sqlServerName string = ''

@description('The sql server reference')
param sqlServerRef object = {}

@description('The database name')
param databaseName string

@description('The sku capacity for the database')
param skuCapacity int

@description('The sku name for the database')
param skuName string

@description('The sku tier for the database')
param skuTier string

@description('The location to deploy the storage account in')
param location string = resourceGroup().location

@description('The tags to be applied to the storage account')
param tags object

// Resource References
resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' existing = {
  name: sqlServerRef != {} ? sqlServerRef.name : sqlServerName
}

// Module Resources
resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  tags: tags

  sku: {
    capacity: skuCapacity
    name: skuName
    tier: skuTier
  }

  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Zone'
  }
}

// Outputs
output sqlDatabaseRef object = {
  subscriptionId: subscription().subscriptionId
  resourceGroupName: resourceGroup().name
  name: sqlDatabase.name
  id: sqlDatabase.id
}
