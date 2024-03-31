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
  name: '${parWorkloadName}-${parSubscriptionScopeIdentifier}'
  parent: apiManagement

  properties: {
    allowTracing: false
    displayName: parWorkloadName
    scope: parSubscriptionScope
  }
}

module keyVaultSecretPrimary './../keyVaultSecret/main.bicep' = {
  name: '${parDeploymentPrefix}-${parSubscriptionScopeIdentifier}-keyVaultSecretPrimary'
  scope: resourceGroup(parWorkloadSubscriptionId, parWorkloadResourceGroupName)

  params: {
    parKeyVaultName: parKeyVaultName
    parSecretName: '${apiManagementSubscription.name}-api-key-primary'
    parSecretValue: apiManagementSubscription.listSecrets(apiManagementSubscription.apiVersion).primaryKey
    parTags: parTags
  }
}

module keyVaultSecretSeconday './../keyVaultSecret/main.bicep' = {
  name: '${parDeploymentPrefix}-${parSubscriptionScopeIdentifier}-keyVaultSecretSecondary'
  scope: resourceGroup(parWorkloadSubscriptionId, parWorkloadResourceGroupName)

  params: {
    parKeyVaultName: parKeyVaultName
    parSecretName: '${apiManagementSubscription.name}-api-key-secondary'
    parSecretValue: apiManagementSubscription.listSecrets(apiManagementSubscription.apiVersion).secondaryKey
    parTags: parTags
  }
}

// Outputs
output outSubscriptionName string = apiManagementSubscription.name
