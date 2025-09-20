# Azure Monitor Domain Controller Monitoring (Bicep)

Infrastructure-as-Code for collecting Windows Event Logs and performance metrics from Active Directory Domain Controllers and generating alerts.

## Components
- Log Analytics Workspace
- Data Collection Rule (Windows Event Logs: System, Application, Directory Service, DNS Server, Security)
- Action Group (email receivers)
- Scheduled Query Alerts (Replication errors, Failed logon spike) – TO FIX: current bicep requires schema adjustment
- Metric Alert (CPU) – placeholder

## Deployment
Adjust `infra/main.parameters.json` then deploy:

```powershell
# Validate
New-AzResourceGroupDeployment -ResourceGroupName <rg> -TemplateFile .\infra\main.bicep -TemplateParameterFile .\infra\main.parameters.json -WhatIf

New-AzResourceGroupDeployment -ResourceGroupName rg-onprem -TemplateFile main.bicep -TemplateParameterFile main.parameters.json -WhatIf

# Deploy
New-AzResourceGroupDeployment -ResourceGroupName <rg> -TemplateFile .\infra\main.bicep -TemplateParameterFile .\infra\main.parameters.json
```

New-AzResourceGroupDeployment -ResourceGroupName rg-onprem -TemplateFile main.bicep -TemplateParameterFile main.parameters.json

(Or convert to `az deployment group create`.)

## Assign the DCRs to the VMs
az extension add --name monitor-control-service --yes

$DcrId = az monitor data-collection rule list -g rg-onprem --query "[?name=='dcr-dc-winevents'].id | [0]" -o tsv


az monitor data-collection rule association create --name default --rule-id $DcrId --resource "/subscriptions/<subId>/resourceGroups/rg-onprem/providers/Microsoft.Compute/virtualMachines/<vm-name>"


## Verify deployments
az monitor data-collection rule association list --resource "/subscriptions/<subId>/resourceGroups/rg-spoke1/providers/Microsoft.Compute/virtualMachines/<vm-name>" -o table


## Validate in a few mins with the following KQLs
Heartbeat
| where Computer startswith "<YourDCName>"
| take 5


Event
| where Source in ('Microsoft-Windows-ActiveDirectory_DomainService','DNS Server','Microsoft-Windows-Time-Service')
| where TimeGenerated > ago(30m)
| summarize count() by Source

## Next Steps
1. Provide exact Event IDs & thresholds.
2. Supply DC VM or Arc resource IDs for `dcResourceIds` in parameters.
3. Replace placeholder email.
4. Fix alert schemas (scheduledQueryRules & metricAlerts) to match stable API versions.

## Notes
Current `alerts.bicep` has lint/type warnings; will be refined next iteration.
