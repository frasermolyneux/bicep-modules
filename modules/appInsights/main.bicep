targetScope = 'resourceGroup'

// Parameters
@description('The app insights name')
param appInsightsName string

@description('The log analytics workspace name (if in-scope)')
param logAnalyticsWorkspaceName string = ''

@description('The log analytics workspace reference (if out-of-scope)')
param logAnalyticsWorkspaceRef object = {}

@description('The location of the resources.')
param location string = resourceGroup().location

@description('The tags to apply to the resources.')
param tags object

// Resource References
resource logAnalyticsWorkspaceInScope 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = if (logAnalyticsWorkspaceRef == {}) {
  name: logAnalyticsWorkspaceName
}

resource logAnalyticsWorkspaceOutOfScope 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = if (logAnalyticsWorkspaceRef != {}) {
  name: logAnalyticsWorkspaceRef.Name
  scope: resourceGroup(logAnalyticsWorkspaceRef.SubscriptionId, logAnalyticsWorkspaceRef.ResourceGroupName)
}

// Module Resources
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  tags: tags

  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceRef == {}
      ? logAnalyticsWorkspaceInScope.id
      : logAnalyticsWorkspaceOutOfScope.id
  }
}

// Outputs
output appInsightsRef object = {
  Name: appInsights.name
  SubscriptionId: subscription().subscriptionId
  ResourceGroupName: resourceGroup().name
}
