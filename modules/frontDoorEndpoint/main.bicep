targetScope = 'resourceGroup'

// Parameters
param parDeploymentPrefix string
param parFrontDoorName string
param parParentDnsName string
param parDnsResourceGroupName string
param parWorkloadName string
param parOriginHostName string
param parDnsZoneHostnamePrefix string
param parCustomHostname string

param parTags object

// Existing In-Scope Resources
resource frontDoor 'Microsoft.Cdn/profiles@2021-06-01' existing = {
  name: parFrontDoorName
}

// Existing Out-Of-Scope Resources
resource parentDnsZone 'Microsoft.Network/dnsZones@2018-05-01' existing = {
  name: parParentDnsName
  scope: resourceGroup(parDnsResourceGroupName)
}

// Module Resources
resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdendpoints@2021-06-01' = {
  parent: frontDoor
  name: parWorkloadName
  location: 'Global'
  tags: parTags

  properties: {
    enabledState: 'Enabled'
  }
}

resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/origingroups@2021-06-01' = {
  parent: frontDoor
  name: '${parWorkloadName}-origin-group'

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
  name: '${parWorkloadName}-origin'

  properties: {
    hostName: parOriginHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: parOriginHostName
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
  }
}

resource frontDoorCustomDomain 'Microsoft.Cdn/profiles/customdomains@2021-06-01' = {
  parent: frontDoor
  name: '${parWorkloadName}-custom-domain'

  properties: {
    hostName: parCustomHostname
    tlsSettings: {
      certificateType: 'ManagedCertificate'
      minimumTlsVersion: 'TLS12'
    }

    azureDnsZone: {
      id: parentDnsZone.id
    }
  }
}

resource frontDoorRoute 'Microsoft.Cdn/profiles/afdendpoints/routes@2021-06-01' = {
  parent: frontDoorEndpoint
  name: '${parWorkloadName}-route'

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

module dnsCNAME 'dnsCNAME.bicep' = {
  name: '${parDeploymentPrefix}-${parWorkloadName}-dnsCNAME'
  scope: resourceGroup(parDnsResourceGroupName)

  params: {
    parDns: parDnsZoneHostnamePrefix
    parParentDnsName: parParentDnsName
    parCname: frontDoorEndpoint.properties.hostName
    parCnameValidationToken: frontDoorCustomDomain.properties.validationProperties.validationToken
    parTags: parTags
  }
}
