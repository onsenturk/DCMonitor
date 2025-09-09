@description('Action Group name')
param actionGroupName string = 'ag-dc-monitor'
@description('Short name (12 chars max)')
@maxLength(12)
param shortName string = 'DCMON'
@description('Email recipients for alerts')
param emailReceivers array = [] // [{ name: 'Ops', emailAddress: 'ops@example.com', useCommonAlertSchema: true }]

resource ag 'Microsoft.Insights/actionGroups@2022-06-15' = {
  name: actionGroupName
  location: 'global'
  properties: {
    groupShortName: shortName
    enabled: true
    emailReceivers: [for e in emailReceivers: {
      name: e.name
      emailAddress: e.emailAddress
      useCommonAlertSchema: e.useCommonAlertSchema == true
    }]
  }
  tags: {
    solution: 'dc-monitor'
  }
}

output actionGroupId string = ag.id
