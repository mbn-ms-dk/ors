targetScope =  'resourceGroup'

param location string = resourceGroup().location

param tags object = {}

param containerappenvironmentname string

param loganalyticsworkspacename string


resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: loganalyticsworkspacename
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
  tags: tags
}

resource containerappenvironment 'Microsoft.App/managedEnvironments@2023-08-01-preview' = {
  name: containerappenvironmentname
  location: location
  tags: tags
  properties: {
   appLogsConfiguration: {
      destination: 'LogAnalytics'
      logAnalyticsConfiguration: {
        customerId: law.id
        sharedKey: law.listKeys().primarySharedKey
      } 
  }
}
}
