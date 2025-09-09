@description('Name of the Log Analytics workspace')
param workspaceName string
@description('Azure region')
param location string
@description('Retention in days (30-730)')
@minValue(30)
@maxValue(730)
param retentionInDays int = 90

resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  sku: {
    name: 'PerGB2018'
  }
  properties: {
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
  tags: {
    'azd-env-name': deployment().name
    solution: 'dc-monitor'
  }
}

output workspaceId string = law.id
output workspaceNameOut string = law.name
output customerId string = law.properties.customerId
