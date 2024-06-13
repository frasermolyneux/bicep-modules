targetScope = 'resourceGroup'

// Parameters
@description('The web app name')
param parWebAppName string

@description('The location of the resource group.')
param parLocation string = resourceGroup().location

@description('The test url path')
param parTestUrl string

@description('The app insights reference')
param parAppInsightsRef object

@description('The tags to apply to the resources.')
param parTags object = resourceGroup().tags

// Existing Resources
resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: parAppInsightsRef.Name
}

// Module Resources
resource availabilityTest 'microsoft.insights/webtests@2022-06-15' = {
  name: '${parWebAppName}-availability-test'
  location: parLocation

  tags: union(parTags, {
    'hidden-link:${appInsights.id}': 'Resource'
  })

  kind: 'standard'

  properties: {
    SyntheticMonitorId: '${parWebAppName}-availability-test'
    Name: '${parWebAppName}-availability-test'
    Enabled: true
    Frequency: 300
    Timeout: 30
    Kind: 'standard'

    RetryEnabled: false

    Locations: [
      {
        Id: 'emea-ru-msa-edge'
      }
      {
        Id: 'emea-nl-ams-azr'
      }
      {
        Id: 'us-va-ash-azr'
      }
    ]

    Request: {
      RequestUrl: parTestUrl
      HttpVerb: 'GET'
      ParseDependentRequests: true
      FollowRedirects: true
    }

    ValidationRules: {
      SSLCheck: false
    }
  }
}
