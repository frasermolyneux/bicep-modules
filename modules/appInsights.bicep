targetScope = 'resourceGroup'

// Parameters
param parAppInsightsName string
param parKeyVaultName string
param parLocation string
param parLoggingSubscriptionId string
param parLoggingResourceGroupName string
param parLoggingWorkspaceName string
param parTags object

// Existing In-Scope Resources
resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: parKeyVaultName
}

// Existing Out-Of-Scope Resources
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  name: parLoggingWorkspaceName
  scope: resourceGroup(parLoggingSubscriptionId, parLoggingResourceGroupName)
}

// Module Resources
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: parAppInsightsName
  location: parLocation
  kind: 'web'
  tags: parTags

  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource appInsightsConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: '${appInsights.name}-connectionstring'
  parent: keyVault
  tags: parTags

  properties: {
    contentType: 'text/plain'
    value: appInsights.properties.ConnectionString
  }
}

resource appInsightsInstrumentationKeySecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: '${appInsights.name}-instrumentationkey'
  parent: keyVault
  tags: parTags

  properties: {
    contentType: 'text/plain'
    value: appInsights.properties.InstrumentationKey
  }
}

// Outputs
output outAppInsightsName string = appInsights.name
