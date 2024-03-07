targetScope = 'resourceGroup'

//paramaters
param location string = resourceGroup().location
param tags object
param containerappenvironmentName string
param appname string
param appPort int
param containerregistryName string

//variables
var containerRegistryPullRoleGuid='7f951dda-4ed3-4680-a7ca-43fe172d538d'

//resources

resource cae 'Microsoft.App/managedEnvironments@2023-08-01-preview' existing ={
  name: containerappenvironmentName
}

//reference existing container registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: containerregistryName
}

//create userassignedidentity 
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${appname}-identity'
  location: location
  tags: tags
}

//assigne acr pull role to userassignedidentity
resource acrRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: '${appname}-acr-role-assignment'
  scope: containerRegistry
  properties: {
    principalId: userAssignedIdentity.properties.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', containerRegistryPullRoleGuid)
    principalType: 'ServicePrincipal'
  }
}

module orsapp 'container-apps/orsblazorapp.bicep' = {
  name: 'orsapp'
  params: {
    location: location
    tags: tags
    containerport: appPort
    managedIdentityId: userAssignedIdentity.id
    containerAppEnvId: cae.id
    containerRegistryName: containerregistryName
  }
  }
