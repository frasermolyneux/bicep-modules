targetScope = 'resourceGroup'

// Parameters
param parDns string
param parParentDnsName string
param parCname string
@secure()
param parCnameValidationToken string
param parTags object

// Existing Resources
resource parentZone 'Microsoft.Network/dnsZones@2018-05-01' existing = {
  name: parParentDnsName
}

// Module Resources
resource cname 'Microsoft.Network/dnszones/CNAME@2018-05-01' = {
  parent: parentZone
  name: parDns

  properties: {
    TTL: 3600
    metadata: parTags
    CNAMERecord: {
      cname: parCname
    }
  }
}

resource authRecord 'Microsoft.Network/dnszones/TXT@2018-05-01' = {
  parent: parentZone
  name: '_dnsauth.${parDns}'

  properties: {
    TTL: 3600
    metadata: parTags
    TXTRecords: [
      {
        value: [
          parCnameValidationToken
        ]
      }
    ]
    targetResource: {
    }
  }
}
