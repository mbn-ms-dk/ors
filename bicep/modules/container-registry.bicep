targetScope = 'resourceGroup'

//parameters

param acrname string = 'acr${uniqueString((resourceGroup().id))}'
param location string = resourceGroup().location
param tags object


resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: acrname
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

output acrName string = acr.name
