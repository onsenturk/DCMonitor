@description('Deployment location')
param location string
@description('Log Analytics workspace name')
param workspaceName string
@description('Email receivers for action group')
param emailReceivers array = []
@description('Domain Controller Azure resource IDs (VMs or Arc machines) for metric alerts scope')
param dcResourceIds array = []
@description('Scope for CPU metric alert (VM/Arc resource IDs) if different from dcResourceIds')
param cpuScope array = []

@description('Workspace retention days')
param retentionInDays int = 90
@description('AD database drive letter instance (e.g. C:, D:) passed to alerts')
param dbDriveInstanceName string = 'C:'
@description('AD log drive letter instance (e.g. C:, D:) passed to alerts')
param logDriveInstanceName string = 'C:'

module law './log-analytics.bicep' = {
  name: 'law'
  params: {
    workspaceName: workspaceName
    location: location
    retentionInDays: retentionInDays
  }
}

module ag './action-group.bicep' = {
  name: 'actionGroup'
  params: {
    emailReceivers: emailReceivers
  }
}

@description('Windows Event DCR for Domain Controllers')
module dcr './dcr-windows-events.bicep' = {
  name: 'dcrWinEvents'
  params: {
    workspaceId: law.outputs.workspaceId
  }
}

// Associate Data Collection Rule with each Domain Controller (supports VM & Arc based on resource ID substring)
module dcrAssoc './dcr-association.bicep' = [for id in dcResourceIds: {
  name: 'dcrAssoc-${uniqueString(id)}'
  params: {
    vmName: contains(toLower(id), 'microsoft.compute/virtualmachines') ? last(split(id, '/')) : ''
    arcMachineName: contains(toLower(id), 'microsoft.hybridcompute/machines') ? last(split(id, '/')) : ''
    dcrId: dcr.outputs.dcrId
    targetType: contains(toLower(id), 'microsoft.compute/virtualmachines') ? 'vm' : 'arc'
  }
}]

// Alerts module (scheduled query + metric)
module alerts './alerts.bicep' = {
  name: 'alerts'
  params: {
    workspaceId: law.outputs.workspaceId
    actionGroupId: ag.outputs.actionGroupId
  cpuScope: length(cpuScope) > 0 ? cpuScope : dcResourceIds
  dbDriveInstanceName: dbDriveInstanceName
  logDriveInstanceName: logDriveInstanceName
  }
}

output workspaceId string = law.outputs.workspaceId
output actionGroupId string = ag.outputs.actionGroupId
output dcrId string = dcr.outputs.dcrId
// (Optional) Could output association IDs if needed; omitted to avoid collection iteration issues.
