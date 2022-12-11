targetScope = 'resourceGroup'

// Parameters
param parKeyVaultName string
param parLocation string
param parTags object

@description('Must be set to "default" if the Key Vault does not exist. Setting to "recover" avoids the accessPolicies being wiped each time.')
param parKeyVaultCreateMode string = 'recover'

param parEnabledForDeployment bool = false
param parEnabledForTemplateDeployment bool = false

param parEnabledForRbacAuthorization bool = false

param parSoftDeleteRetentionInDays int = 90

// Module Resources
resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: parKeyVaultName
  location: parLocation
  tags: parTags

  properties: {
    accessPolicies: []
    createMode: parKeyVaultCreateMode

    enablePurgeProtection: true
    enableRbacAuthorization: parEnabledForRbacAuthorization
    enabledForDeployment: parEnabledForDeployment
    enabledForTemplateDeployment: parEnabledForTemplateDeployment

    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }

    sku: {
      family: 'A'
      name: 'standard'
    }

    softDeleteRetentionInDays: parSoftDeleteRetentionInDays

    tenantId: tenant().tenantId
  }
}

// Outputs
output outKeyVaultName string = keyVault.name
