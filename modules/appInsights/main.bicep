targetScope = 'resourceGroup'

// Parameters
param parAppInsightsName string
param parLocation string
param parLoggingSubscriptionId string
param parLoggingResourceGroupName string
param parLoggingWorkspaceName string
param parTags object

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

// Outputs
output outAppInsightsName string = appInsights.name
