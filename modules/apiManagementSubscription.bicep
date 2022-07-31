targetScope = 'resourceGroup'

// Parameters
param parDeploymentPrefix string
param parApiManagementName string
param parWorkloadSubscriptionId string
param parWorkloadResourceGroupName string
param parWorkloadName string
param parKeyVaultName string
param parSubscriptionScopeIdentifier string
param parSubscriptionScope string
param parTags object

// Existing In-Scope Resources
resource apiManagement 'Microsoft.ApiManagement/service@2021-12-01-preview' existing = {
  name: parApiManagementName
}

// Module Resources
resource apiManagementSubscription 'Microsoft.ApiManagement/service/subscriptions@2021-08-01' = {
  name: '${parWorkloadName}-${parSubscriptionScopeIdentifier}-subscription'
  parent: apiManagement

  properties: {
    allowTracing: false
    displayName: parWorkloadName
    scope: parSubscriptionScope
  }
}

module keyVaultSecret 'keyVaultSecret.bicep' = {
  name: '${parDeploymentPrefix}-${parSubscriptionScopeIdentifier}-keyVaultSecret'
  scope: resourceGroup(parWorkloadSubscriptionId, parWorkloadResourceGroupName)

  params: {
    parKeyVaultName: parKeyVaultName
    parSecretName: '${apiManagement.name}-${apiManagementSubscription.name}-apikey'
    parSecretValue: apiManagementSubscription.properties.primaryKey
    parTags: parTags
  }
}

// Outputs
output outSubscriptionName string = apiManagementSubscription.name
