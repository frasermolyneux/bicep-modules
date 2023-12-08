targetScope = 'resourceGroup'

// Parameters
@description('The api management resource name')
param parApiManagementName string

@description('The app insights reference')
param parAppInsightsRef object

// Existing In-Scope Resources
resource apiManagement 'Microsoft.ApiManagement/service@2021-12-01-preview' existing = {
  name: parApiManagementName
}

// Existing Out-Of-Scope Resources
resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: parAppInsightsRef.Name
  scope: resourceGroup(parAppInsightsRef.SubscriptionId, parAppInsightsRef.ResourceGroupName)
}

// Module Resources
resource apiManagementLogger 'Microsoft.ApiManagement/service/loggers@2021-08-01' = {
  name: appInsights.name
  parent: apiManagement

  properties: {
    credentials: {
      instrumentationKey: appInsights.properties.InstrumentationKey
    }
    loggerType: 'applicationInsights'
    resourceId: appInsights.id
  }
}
