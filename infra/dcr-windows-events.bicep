@description('Target Log Analytics workspace resource ID')
param workspaceId string
@description('Data Collection Rule name')
param dcrName string = 'dcr-dc-winevents'
@description('Event Log channels to collect from')
param channels array = [
  {
    name: 'System'
    xPathQueries: [ '*' ]
  }
  {
    name: 'Application'
    xPathQueries: [ '*' ]
  }
  {
    name: 'Directory Service'
    xPathQueries: [ '*' ]
  }
  {
    name: 'DNS Server'
    xPathQueries: [ '*' ]
  }
  {
    name: 'Security'
    xPathQueries: [ '*' ]
  }
]

@description('Enable performance counter collection (LogicalDisk % Free Space)')
param enablePerfCounters bool = true

// Construct optional arrays via variables for clarity
var perfCounters = enablePerfCounters ? [
  {
    name: 'perf-logicaldisk-freespace'
    streams: [ 'Microsoft-Perf' ]
    samplingFrequencyInSeconds: 60
    counterSpecifiers: [
      '\\LogicalDisk(*)\\% Free Space'
    ]
  }
] : []

resource dcr 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: dcrName
  location: resourceGroup().location
  properties: {
    destinations: {
      logAnalytics: [
        {
          name: 'ladest'
          workspaceResourceId: workspaceId
        }
      ]
    }
    dataFlows: concat([
      {
        streams: [ 'Microsoft-Event' ]
        destinations: [ 'ladest' ]
        transformKql: ''
      }
    ], enablePerfCounters ? [
      {
        streams: [ 'Microsoft-Perf' ]
        destinations: [ 'ladest' ]
        transformKql: ''
      }
    ] : [])
    dataSources: {
      windowsEventLogs: [for c in channels: {
        name: 'wev-${toLower(replace(c.name, ' ', '-'))}'
        streams: [ 'Microsoft-Event' ]
        xPathQueries: c.xPathQueries
      }]
      performanceCounters: perfCounters
    }
  }
  tags: {
    solution: 'dc-monitor'
  }
}

output dcrId string = dcr.id
