@description('Azure VM resource name (if VM association). Mutually exclusive with arcMachineName.')
param vmName string = ''
@description('Arc machine resource name (if Arc association). Mutually exclusive with vmName.')
param arcMachineName string = ''
@description('Data Collection Rule resource ID.')
param dcrId string

@allowed(['vm','arc'])
@description('Association target type')
param targetType string

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' existing = if(targetType == 'vm') {
  name: vmName
}
resource arc 'Microsoft.HybridCompute/machines@2023-07-30' existing = if(targetType == 'arc') {
  name: arcMachineName
}

resource assoc 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = if(targetType == 'vm') {
  name: 'default'
  scope: vm
  properties: {
    dataCollectionRuleId: dcrId
    description: 'Domain Controller log & performance collection'
  }
}

resource assocArc 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = if(targetType == 'arc') {
  name: 'default'
  scope: arc
  properties: {
    dataCollectionRuleId: dcrId
    description: 'Domain Controller log & performance collection'
  }
}

output associationId string = targetType == 'vm' ? assoc.id : assocArc.id
