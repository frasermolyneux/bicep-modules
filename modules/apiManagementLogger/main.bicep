targetScope = 'resourceGroup'

// Parameters
param parApiManagementName string
param parWorkloadSubscriptionId string
param parWorkloadResourceGroupName string
param parAppInsightsName string
param parKeyVaultName string

// Existing In-Scope Resources
resource apiManagement 'Microsoft.ApiManagement/service@2021-12-01-preview' existing = {
  name: parApiManagementName
}

// Existing Out-Of-Scope Resources
resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: parAppInsightsName
  scope: resourceGroup(parWorkloadSubscriptionId, parWorkloadResourceGroupName)
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: parKeyVaultName
  scope: resourceGroup(parWorkloadSubscriptionId, parWorkloadResourceGroupName)
}

// Module Resources
resource appInsightsInstrumentationKeyNamedValue 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  name: '${appInsights.name}-instrumentationkey'
  parent: apiManagement

  properties: {
    displayName: '${appInsights.name}-instrumentationkey'
    keyVault: {
      secretIdentifier: '${keyVault.properties.vaultUri}secrets/${appInsights.name}-instrumentationkey'
    }
    secret: true
  }
}

resource apiManagementLogger 'Microsoft.ApiManagement/service/loggers@2021-08-01' = {
  name: parAppInsightsName
  parent: apiManagement

  properties: {
    credentials: {
      instrumentationKey: '{{${appInsightsInstrumentationKeyNamedValue.properties.displayName}}}'
    }
    loggerType: 'applicationInsights'
    resourceId: appInsights.id
  }
}
