targetScope = 'resourceGroup'

param location string = resourceGroup().location

param tags object  = {
  environment: 'dev'
  costcenter: 'notmine'
}

param containerappenvironmentname string 

param lognzlyticsworkspace string

param orsappname string
param orsportnumber int


module cae 'modules/cae.bicep' = {
  name: 'cae'
  params: {
    location: location
    tags: tags
    containerappenvironmentname: containerappenvironmentname
    loganalyticsworkspacename: lognzlyticsworkspace
  }
}

module acr 'modules/container-registry.bicep' = {
  name: 'acr'
  params: {
    location: location
    tags: tags
  }
}

module apps 'modules/deploy-apps.bicep' = {
  name: 'apps'
  params: {
    location: location
    tags: tags
    containerappenvironmentName: containerappenvironmentname
    appname: orsappname
    appPort: orsportnumber
    containerregistryName: acr.outputs.acrName
  }
}
