targetScope = 'resourceGroup'

// Parameters
@description('The api management name')
param apiManagementName string

@description('The app insights name (if in-scope)')
param appInsightsName string = ''

@description('The app insights reference (if out-of-scope)')
param appInsightsRef object = {}

// Resource References
resource apiManagement 'Microsoft.ApiManagement/service@2021-12-01-preview' existing = {
  name: apiManagementName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsRef != {} ? appInsightsRef.name : appInsightsName
  scope: resourceGroup(
    appInsightsRef != {} ? appInsightsRef.SubscriptionId : subscription().subscriptionId,
    appInsightsRef != {} ? appInsightsRef.ResourceGroupName : resourceGroup().name
  )
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
