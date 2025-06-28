targetScope = 'resourceGroup'

// Parameters
@description('The api management resource name')
param apiManagementName string

@description('The workload name')
param workloadName string

@description('The api scope (deprecated - use scope parameter instead)')
param apiScope string = ''

@description('The scope in format like "/products/{productId}" or "/apis" or "/apis/{apiId}"')
param scope string = ''

@description('The key vault resource name')
param keyVaultName string = ''

@description('A reference to the key vault resource')
param keyVaultRef object = {}

@description('The tags to apply to the resources')
param tags object

// Variables
// Determine the effective scope based on provided parameters
// If 'scope' is provided, use it directly; otherwise construct from 'apiScope' (for backward compatibility)
var effectiveScope = scope != '' ? scope : (apiScope != '' ? '/apis/${apiScope}' : '')

// Extract a meaningful suffix for the subscription name from the scope
// For product scopes like '/products/my-product', this will extract 'my-product'
// For API scopes, it will use the apiScope value directly
var subscriptionNameSuffix = scope != '' ? last(split(scope, '/')) : apiScope
var subscriptionName = '${workloadName}-${subscriptionNameSuffix}'

// Resource References
resource apiManagement 'Microsoft.ApiManagement/service@2024-05-01' existing = {
  name: apiManagementName
}

// Module Resources
resource apiManagementSubscription 'Microsoft.ApiManagement/service/subscriptions@2024-05-01' = {
  name: subscriptionName
  parent: apiManagement

  properties: {
    allowTracing: false
    displayName: subscriptionName
    scope: effectiveScope
  }
}

module keyVaultSecretPrimary './../keyVaultSecret/main.bicep' = {
  name: 'api-key-primary-${uniqueString(subscriptionName)}'
  scope: resourceGroup(
    keyVaultRef != {} ? keyVaultRef.SubscriptionId : subscription().subscriptionId,
    keyVaultRef != {} ? keyVaultRef.ResourceGroupName : resourceGroup().name
  )

  params: {
    keyVaultName: keyVaultRef != {} ? keyVaultRef.name : keyVaultName
    secretName: '${apiManagementSubscription.name}-api-key-primary'
    secretValue: apiManagementSubscription.listSecrets(apiManagementSubscription.apiVersion).primaryKey
    tags: tags
  }
}

module keyVaultSecretSecondary './../keyVaultSecret/main.bicep' = {
  name: 'api-key-secondary-${uniqueString(subscriptionName)}'
  scope: resourceGroup(
    keyVaultRef != {} ? keyVaultRef.SubscriptionId : subscription().subscriptionId,
    keyVaultRef != {} ? keyVaultRef.ResourceGroupName : resourceGroup().name
  )

  params: {
    keyVaultName: keyVaultRef != {} ? keyVaultRef.name : keyVaultName
    secretName: '${apiManagementSubscription.name}-api-key-secondary'
    secretValue: apiManagementSubscription.listSecrets(apiManagementSubscription.apiVersion).secondaryKey
    tags: tags
  }
}

// Outputs
output subscriptionName string = apiManagementSubscription.name
output primaryKeySecretRef object = keyVaultSecretPrimary.outputs.secretRef
output secondaryKeySecretRef object = keyVaultSecretSecondary.outputs.secretRef
