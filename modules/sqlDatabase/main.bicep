targetScope = 'resourceGroup'

// Parameters
param parSqlServerName string

param parLocation string

param parDatabaseName string
param parSkuCapacity int
param parSkuName string
param parSkuTier string

param parTags object

// Existing In-Scope Resources
resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' existing = {
  name: parSqlServerName
}

// Module Resources
resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  parent: sqlServer
  name: parDatabaseName
  location: parLocation
  tags: parTags

  sku: {
    capacity: parSkuCapacity
    name: parSkuName
    tier: parSkuTier
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
