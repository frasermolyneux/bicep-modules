targetScope = 'resourceGroup'

// Parameters
@description('The workload name')
param workloadName string

@description('The test url path')
param testUrl string

@description('The app insights resource name')
param appInsightsName string = ''

@description('A reference to the app insights resource')
param appInsightsRef object = {}

@description('The location to deploy the resources')
param location string = resourceGroup().location

@description('The tags to apply to the resources')
param tags object

// Existing Resources
resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsRef != {} ? appInsightsRef.name : appInsightsName
}

// Module Resources
resource availabilityTest 'microsoft.insights/webtests@2022-06-15' = {
  name: '${workloadName}-availability-test'
  location: location

  tags: union(tags, {
    'hidden-link:${appInsights.id}': 'Resource'
  })

  kind: 'standard'

  properties: {
    SyntheticMonitorId: '${workloadName}-availability-test'
    Name: '${workloadName}-availability-test'
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
      RequestUrl: testUrl
      HttpVerb: 'GET'
      ParseDependentRequests: true
      FollowRedirects: true
    }

    ValidationRules: {
      SSLCheck: false
    }
  }
}
