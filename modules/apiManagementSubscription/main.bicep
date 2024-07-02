targetScope = 'resourceGroup'

// Parameters
@description('The api management name')
param apiManagementName string

@description('The subscription name')
param subscriptionName string

@description('The api scope')
param apiScope string

@description('The key vault name (if in-scope)')
param keyVaultName string = ''

@description('The key vault reference (if out-of-scope)')
param keyVaultRef object = {}

@description('The tags to apply to the resources.')
param tags object

// Resource References
resource apiManagement 'Microsoft.ApiManagement/service@2021-12-01-preview' existing = {
  name: apiManagementName
}

// Module Resources
resource apiManagementSubscription 'Microsoft.ApiManagement/service/subscriptions@2021-08-01' = {
  name: '${subscriptionName}-${apiScope}'
  parent: apiManagement

  properties: {
    allowTracing: false
    displayName: subscriptionName
    scope: apiScope
  }
}

module keyVaultSecretPrimaryInScope './../keyVaultSecret/main.bicep' = if (keyVaultRef == {}) {
  name: '${subscriptionName}-${apiScope}-keyVaultSecretPrimary'

  params: {
    parKeyVaultName: keyVaultName
    parSecretName: '${apiManagementSubscription.name}-api-key-primary'
    parSecretValue: apiManagementSubscription.listSecrets(apiManagementSubscription.apiVersion).primaryKey
    parTags: tags
  }
}

module keyVaultSecretSecondaryInScope './../keyVaultSecret/main.bicep' = if (keyVaultRef == {}) {
  name: '${subscriptionName}-${apiScope}-keyVaultSecretSecondary'

  params: {
    parKeyVaultName: keyVaultName
    parSecretName: '${apiManagementSubscription.name}-api-key-secondary'
    parSecretValue: apiManagementSubscription.listSecrets(apiManagementSubscription.apiVersion).secondaryKey
    parTags: tags
  }
}

module keyVaultSecretPrimaryOutOfScope './../keyVaultSecret/main.bicep' = if (keyVaultRef != {}) {
  name: '${subscriptionName}-${apiScope}-keyVaultSecretPrimary'
  scope: resourceGroup(keyVaultRef.SubscriptionId, keyVaultRef.ResourceGroupName)

  params: {
    parKeyVaultName: keyVaultName
    parSecretName: '${apiManagementSubscription.name}-api-key-primary'
    parSecretValue: apiManagementSubscription.listSecrets(apiManagementSubscription.apiVersion).primaryKey
    parTags: tags
  }
}

module keyVaultSecretSecondaryOutOfScope './../keyVaultSecret/main.bicep' = if (keyVaultRef != {}) {
  name: '${subscriptionName}-${apiScope}-keyVaultSecretSecondary'
  scope: resourceGroup(keyVaultRef.SubscriptionId, keyVaultRef.ResourceGroupName)

  params: {
    parKeyVaultName: keyVaultName
    parSecretName: '${apiManagementSubscription.name}-api-key-secondary'
    parSecretValue: apiManagementSubscription.listSecrets(apiManagementSubscription.apiVersion).secondaryKey
    parTags: tags
  }
}

// Outputs
output outSubscriptionName string = apiManagementSubscription.name
