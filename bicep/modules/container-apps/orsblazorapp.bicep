targetScope = 'resourceGroup'

//parameters

//add location
param location string = resourceGroup().location
//add parameter tags
param tags object = {}
//set parameter for container app environment name
param containerAppEnvId string
//set parameter for container registry name
param containerRegistryName string
//set paramter for managed identity name
param managedIdentityId string

param containerport int

//modules
module orsapp 'br/public:deployment-scripts/build-acr:2.0.1' = {
  name: 'orstedapp'
  params: {
    AcrName: containerRegistryName
    location: location
    gitRepositoryUrl:  'https://github.com/mbn-ms-dk/ors.git'
    dockerfileDirectory: 'OrsBlazor'
    imageName: 'ors/orsapp'
    imageTag: 'latest'
    cleanupPreference: 'Always'
  }
}

//create azure container app resource
resource orsappres 'Microsoft.App/containerApps@2023-08-01-preview' = {
  name: 'orsapp'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
          '${managedIdentityId}' : {}
      }
    }
  properties: {
      managedEnvironmentId: containerAppEnvId
      configuration: {
        activeRevisionsMode: 'single'
        ingress: {
          external: true
          targetPort: containerport
        }
        registries: [
          {
          server: '${containerRegistryName}.azurecr.io'
          identity: managedIdentityId
          }
        ]
      }
      template: {
        containers: [
          {
          name: 'orsapp'
          image: orsapp.outputs.acrImage
          resources: {
              cpu: json('0.5')
              memory: '0.5Gi'
          } 
        }
        ]
        scale: {
          minReplicas: 1
          maxReplicas: 3
        }
      }
      }
    }

