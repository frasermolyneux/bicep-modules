targetScope = 'resourceGroup'

// Parameters
@description('The api management resource name')
param apiManagementName string

@description('The workload name')
param workloadName string

@description('The api scope')
param apiScope string

@description('The key vault resource name')
param keyVaultName string = ''

@description('A reference to the key vault resource')
param keyVaultRef object = {}

@description('The tags to apply to the resources')
param tags object

// Variables
var subscriptionName = '${workloadName}-${apiScope}'

// Resource References
resource apiManagement 'Microsoft.ApiManagement/service@2021-12-01-preview' existing = {
  name: apiManagementName
}

// Module Resources
resource apiManagementSubscription 'Microsoft.ApiManagement/service/subscriptions@2021-08-01' = {
  name: subscriptionName
  parent: apiManagement

  properties: {
    allowTracing: false
    displayName: subscriptionName
    scope: '/apis/${apiScope}'
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
