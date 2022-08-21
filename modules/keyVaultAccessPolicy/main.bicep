targetScope = 'resourceGroup'

// Parameters
param parKeyVaultName string
param parPrincipalId string

param parSecretsPermissions array = [
  'get'
]

// Existing In-Scope Resources
resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: parKeyVaultName
}

// Module Resources
resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-11-01-preview' = {
  name: 'add'
  parent: keyVault

  properties: {
    accessPolicies: [
      {
        objectId: parPrincipalId
        permissions: {
          certificates: []
          keys: []
          secrets: parSecretsPermissions
          storage: []
        }
        tenantId: tenant().tenantId
      }
    ]
  }
}
