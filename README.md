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

## Next Steps
1. Provide exact Event IDs & thresholds.
2. Supply DC VM or Arc resource IDs for `dcResourceIds` in parameters.
3. Replace placeholder email.
4. Fix alert schemas (scheduledQueryRules & metricAlerts) to match stable API versions.

## Notes
Current `alerts.bicep` has lint/type warnings; will be refined next iteration.
