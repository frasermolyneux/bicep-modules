targetScope = 'resourceGroup'

// Parameters
@description('The key vault name')
param keyVaultName string = ''

@description('The key vault reference')
param keyVaultRef object = {}

@description('The principal id to grant access to the key vault')
param principalId string

@description('The permissions to grant to the key vault')
param secretsPermissions array = [
  'get'
]

// Resource References
resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultRef != {} ? keyVaultRef.name : keyVaultName
}

// Module Resources
resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-11-01-preview' = {
  name: 'add'
  parent: keyVault

  properties: {
    accessPolicies: [
      {
        objectId: principalId
        permissions: {
          certificates: []
          keys: []
          secrets: secretsPermissions
          storage: []
        }
        tenantId: tenant().tenantId
      }
    ]
  }
}
