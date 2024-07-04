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
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(
    logAnalyticsWorkspaceRef != {} ? logAnalyticsWorkspaceRef.SubscriptionId : subscription().subscriptionId,
    logAnalyticsWorkspaceRef != {} ? logAnalyticsWorkspaceRef.ResourceGroupName : resourceGroup().name
  )
}

// Module Resources
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  tags: tags

  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

// Outputs
output appInsightsRef object = {
  Name: appInsights.name
  SubscriptionId: subscription().subscriptionId
  ResourceGroupName: resourceGroup().name
}
