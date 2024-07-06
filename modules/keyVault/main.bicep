targetScope = 'resourceGroup'

// Parameters
@description('The key vault resource name')
param keyVaultName string = ''

@description('The environment for the resources')
param environment string = ''

@description('The workload the storage account is for (must set if not providing keyVaultName)')
param workload string = ''

@description('Must be set to "default" if the Key Vault does not exist. Setting to "recover" avoids the accessPolicies being wiped each time.')
param keyVaultCreateMode string = 'recover'

@description('Enable the key vault for deployment')
param enabledForDeployment bool = false

@description('Enable the key vault for template deployment')
param enabledForTemplateDeployment bool = false

@description('Enable the key vault for rbac authorization')
param enabledForRbacAuthorization bool = true

@description('Enable the key vault for deployment')
param softDeleteRetentionInDays int = 90

@description('The location to deploy the resources')
param location string = resourceGroup().location

@description('The tags to apply to the resources')
param tags object

// Module Resources
resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: !empty(keyVaultName) ? keyVaultName : 'kv${uniqueString(resourceGroup().id, workload, environment)}-${location}'
  location: location
  tags: tags

  properties: {
    accessPolicies: []
    createMode: keyVaultCreateMode

    enablePurgeProtection: true
    enableRbacAuthorization: enabledForRbacAuthorization
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment

    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }

    sku: {
      family: 'A'
      name: 'standard'
    }

    softDeleteRetentionInDays: softDeleteRetentionInDays

    tenantId: tenant().tenantId
  }
}

// Outputs
output keyVaultRef object = {
  subscriptionId: subscription().subscriptionId
  resourceGroupName: resourceGroup().name
  name: keyVault.name
  id: keyVault.id
}
