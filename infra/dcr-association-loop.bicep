@description('Data Collection Rule resource ID')
param dcrId string
@description('List of Domain Controller resource IDs (VMs or Arc machines)')
param dcResourceIds array

// Output array of association IDs
var assocIds = [for (id, i) in dcResourceIds: {
  id: id
  index: i
}]

// Expand each into module of single association using existing module file not needed; implement inline resources via copy pattern.
// We need to detect type per resource ID. We'll create two associations per entry with mutually exclusive conditions.

resource assocVm 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = [for (dcId, i) in dcResourceIds: if(contains(toLower(dcId), 'microsoft.compute/virtualmachines')) {
  name: 'vm-${i}'
  scope: resourceId(split(dcId, '/')[2], // subscriptions
    substring(dcId, 0, 0) // placeholder to force invalid? (Will fail) 
  )
}]

// NOTE: Placeholder file - Implementation requires manual resource scoping which Bicep doesn't support with dynamic id easily without existing resource blocks.
// Given complexity, prefer using top-level module iteration invoking dcr-association.bicep individually from main instead of loop module.

output associationIds array = []
