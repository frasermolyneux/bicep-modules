targetScope = 'resourceGroup'

// Parameters
@description('The key vault name')
param keyVaultName string = ''

@description('The key vault reference')
param keyVaultRef object = {}

@description('The principal id to grant access to the key vault')
param principalId string

@description('The role definition id to grant to the key vault')
param roleDefinitionId string

// Resource References
resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultRef != {} ? keyVaultRef.name : keyVaultName
}

// Module Resources
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(keyVault.id, principalId, roleDefinitionId)
  scope: keyVault

  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
