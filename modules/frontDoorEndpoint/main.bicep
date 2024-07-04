targetScope = 'resourceGroup'

// Parameters
@description('The front door resource name')
param frontDoorName string

@description('The DNS zone name (if in-scope)')
param dnsZoneName string = ''

@description('The DNS zone reference (if out-of-scope)')
param dnsZoneRef object = {}

@description('The subdomain for the dns zone')
param subdomain string

@description('The origin hostname')
param originHostName string

@description('The tags to apply to the resources.')
param tags object

// Resource References
resource frontDoor 'Microsoft.Cdn/profiles@2021-06-01' existing = {
  name: frontDoorName
}

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' existing = {
  name: dnsZoneRef != {} ? dnsZoneRef.name : dnsZoneName
  scope: resourceGroup(
    dnsZoneRef != {} ? dnsZoneRef.SubscriptionId : subscription().subscriptionId,
    dnsZoneRef != {} ? dnsZoneRef.ResourceGroupName : resourceGroup().name
  )
}

// Module Resources
resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdendpoints@2021-06-01' = {
  parent: frontDoor
  name: '${subdomain}.${dnsZone.name}'
  location: 'Global'
  tags: tags

  properties: {
    enabledState: 'Enabled'
  }
}

resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/origingroups@2021-06-01' = {
  parent: frontDoor
  name: '${subdomain}.${dnsZone.name}-origin-group'

  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }

    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }

    sessionAffinityState: 'Disabled'
  }
}

resource frontDoorOrigin 'Microsoft.Cdn/profiles/origingroups/origins@2021-06-01' = {
  parent: frontDoorOriginGroup
  name: '${subdomain}.${dnsZone.name}-origin'

  properties: {
    hostName: originHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: originHostName
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
  }
}

resource frontDoorCustomDomain 'Microsoft.Cdn/profiles/customdomains@2021-06-01' = {
  parent: frontDoor
  name: '${subdomain}.${dnsZone.name}-custom-domain'

  properties: {
    hostName: '${subdomain}.${dnsZone.name}'
    tlsSettings: {
      certificateType: 'ManagedCertificate'
      minimumTlsVersion: 'TLS12'
    }

    azureDnsZone: {
      id: dnsZone.id
    }
  }
}

resource frontDoorRoute 'Microsoft.Cdn/profiles/afdendpoints/routes@2021-06-01' = {
  parent: frontDoorEndpoint
  name: '${subdomain}.${dnsZone.name}-route'

  properties: {
    customDomains: [
      {
        id: frontDoorCustomDomain.id
      }
    ]

    originGroup: {
      id: frontDoorOriginGroup.id
    }

    ruleSets: []
    supportedProtocols: [
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }
}

module dnsCNAME './../frontDoorCNAME/main.bicep' = {
  name: '${subdomain}.${dnsZone.name}-frontDoorCNAME'
  scope: resourceGroup(
    dnsZoneRef != {} ? dnsZoneRef.SubscriptionId : subscription().subscriptionId,
    dnsZoneRef != {} ? dnsZoneRef.ResourceGroupName : resourceGroup().name
  )

  params: {
    domain: dnsZone.name
    subdomain: subdomain
    cname: frontDoorEndpoint.properties.hostName
    cnameValidationToken: frontDoorCustomDomain.properties.validationProperties.validationToken
    tags: tags
  }
}
