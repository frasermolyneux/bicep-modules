targetScope = 'resourceGroup'

// Parameters
@description('The domain for the record')
param domain string

@description('The subdomain for the record')
param subdomain string

@description('The cname value for the record')
param cname string

@secure()
@description('The cname validation token for the record')
param cnameValidationToken string

@description('The tags to apply to the resources')
param tags object

// Resource References
resource parentZone 'Microsoft.Network/dnsZones@2018-05-01' existing = {
  name: domain
}

// Module Resources
resource cnameRecord 'Microsoft.Network/dnszones/CNAME@2018-05-01' = {
  parent: parentZone
  name: subdomain

  properties: {
    TTL: 3600
    metadata: tags
    CNAMERecord: {
      cname: cname
    }
  }
}

resource authRecord 'Microsoft.Network/dnszones/TXT@2018-05-01' = {
  parent: parentZone
  name: '_dnsauth.${domain}'

  properties: {
    TTL: 3600
    metadata: tags
    TXTRecords: [
      {
        value: [
          cnameValidationToken
        ]
      }
    ]
    targetResource: {}
  }
}
