# Domain Controller Monitoring Alerts

This document lists all Azure Monitor alerts provisioned by the Bicep templates in this repository. The scheduled query (log) alerts are created from `infra/alerts.bicep` via a single loop over an `alertDefinitions` array. A conditional metric alert (CPU) is also included when scope resources are provided.

## Naming
- Prefix parameter: `alertPrefix` (default: `dc`)
- Final alert rule name: `${alertPrefix}-{nameSuffix}`
- Tags applied: `solution=dc-monitor`, `category=ad-domain-controller` (scheduled query alerts)

## Evaluation Defaults
Unless otherwise noted:
- Evaluation frequency: 5 minutes (`PT5M`)
- Query window: 5 minutes (`PT5M`)
- Alert fires on the first occurrence (threshold count >= 1) or for disk space when average free % < threshold.
- Auto-mitigation enabled.

## Parameterized Elements
- Database drive logical disk instance: `dbDriveInstanceName` (default `C:`)
- Log drive logical disk instance: `logDriveInstanceName` (default `C:`)
- Prefix: `alertPrefix`
- CPU alert threshold & severity: `cpuThreshold` (default 85), `cpuSeverity` (default 2 / Medium)
- Extended security / performance thresholds:
	- `failedLogonThreshold` (default 20)
	- `accountLockoutThreshold` (default 3)
	- `kerberosPreauthFailureThreshold` (default 25)
	- `lsassPrivateBytesThresholdBytes` (default 6442450944)

## Scheduled Query Alerts (54)
| # | Rule Name (default) | Display Name | Severity | Freq | Window | Condition | Description |
|--:|----------------------|--------------|---------|------|--------|-----------|-------------|
| 1 | dc-ad-db-corrupt | AD DB Corrupt | Critical (0) | PT5M | PT5M | EventCount >= 1 | Active Directory database is corrupt |
| 2 | dc-ad-disk-full | AD DB Disk Full | Critical (0) | PT5M | PT5M | EventCount >= 1 | AD cannot update object because disk with database is full |
| 3 | dc-replication-all-failing | All Replication Partners Failing | Critical (0) | PT5M | PT5M | EventCount >= 1 | All replication partners failing |
| 4 | dc-netlogon-machine-deleted | DC Machine Account Deleted | Critical (0) | PT5M | PT5M | EventCount >= 1 | DC will not start because its machine account has been deleted |
| 5 | dc-dns-zone-expired | DNS Zone Expired | Critical (0) | PT5M | PT5M | EventCount >= 1 | DNS Zone Expired |
| 6 | dc-dns-zone-not-loaded | DNS Zone Not Loaded | Critical (0) | PT5M | PT5M | EventCount >= 1 | DNS Zone Not loaded |
| 7 | dc-kdc-service-stopped | KDC Service Not Running | Critical (0) | PT5M | PT5M | EventCount >= 1 | Kerberos KDC service stopped |
| 8 | dc-lingering-object | Lingering Object Detected | Critical (0) | PT5M | PT5M | EventCount >= 1 | Lingering object detected; replication blocked |
| 9 | dc-adds-service-stopped | AD DS Service Stopped | Critical (0) | PT5M | PT5M | EventCount >= 1 | AD DS service stopped |
| 10 | dc-sysvol-unavailable | SYSVOL Unavailable | Critical (0) | PT5M | PT5M | EventCount >= 1 | SYSVOL share unavailable |
| 11 | dc-no-longer-dc | Server No Longer DC | Critical (0) | PT5M | PT5M | EventCount >= 1 | Server no longer a domain controller |
| 12 | dc-mutual-auth-spn | Mutual Auth SPN Issue | High (1) | PT5M | PT5M | EventCount >= 1 | Cannot construct mutual authentication SPN |
| 13 | dc-replication-delayed | Replication Delayed | High (1) | PT5M | PT5M | EventCount >= 1 | Replication error / delayed |
| 14 | dc-dhcp-service-stopped | DHCP Service Stopped | High (1) | PT5M | PT5M | EventCount >= 1 | DHCP Service stopped |
| 15 | dc-dns-registration-failing | DNS Registration Failing | High (1) | PT5M | PT5M | EventCount >= 1 | Essential DC DNS registrations failing |
| 16 | dc-schema-master-bind-fail | Schema Master Bind Fail | High (1) | PT5M | PT5M | EventCount >= 1 | Failed to ping/bind Schema Master |
| 17 | dc-gc-promotion-failed | GC Promotion Failed | High (1) | PT5M | PT5M | EventCount >= 1 | Failed to promote server into Global Catalog |
| 18 | dc-disk-free-any-low | Logical Disk Free Space Low | High (1) | PT5M | PT5M | AvgFreePct < 10 | Any logical disk free space <10% |
| 19 | dc-disk-free-db-low | AD DB Drive Free Space Low | High (1) | PT5M | PT5M | AvgFreePct < 15 | DB drive free space <15% |
| 20 | dc-disk-free-log-low | AD Log Drive Free Space Low | High (1) | PT5M | PT5M | AvgFreePct < 15 | Log drive free space <15% |
| 21 | dc-netlogon-stopped | NetLogon Service Stopped | High (1) | PT5M | PT5M | EventCount >= 1 | NetLogon service not running |
| 22 | dc-replicated-object-missing | Replicated Object Missing | High (1) | PT5M | PT5M | EventCount >= 1 | Replicated object missing may be garbage collected |
| 23 | dc-schema-change-modify | Schema Change Modify | High (1) | PT5M | PT5M | EventCount >= 1 | Schema modify event |
| 24 | dc-demotion | System Demotion | High (1) | PT5M | PT5M | EventCount >= 1 | Domain controller demotion |
| 25 | dc-unexpected-shutdown | Unexpected Shutdown | High (1) | PT5M | PT5M | EventCount >= 1 | DC unexpected shutdown |
| 26 | dc-pdc-role-change | PDC Role Change | High (1) | PT5M | PT5M | EventCount >= 1 | Server promoted to PDC Emulator |
| 27 | dc-time-skew | Time Skew Above Threshold | High (1) | PT5M | PT5M | EventCount >= 1 | Time skew above threshold |
| 28 | dc-time-no-sources | Time Sync No Sources | High (1) | PT5M | PT5M | EventCount >= 1 | No time sources available |
| 29 | dc-time-sync-stopped | Time Sync Stopped | High (1) | PT5M | PT5M | EventCount >= 1 | Time Sync stopped |
| 30 | dc-lanmanserver-stopped | Server Service Stopped | High (1) | PT5M | PT5M | EventCount >= 1 | Windows Server (LanmanServer) service stopped |
| 31 | dc-promotion | System Promotion | Info (4) | PT5M | PT15M | EventCount >= 1 | Domain controller promotion (informational) |
| 32 | dc-wins-service | WINS Service State Change | Low (3) | PT5M | PT15M | EventCount >= 1 | WINS service state change |
| 33 | dc-dns-service-restart | DNS Service Restarted or Stopped | Medium (2) | PT5M | PT5M | EventCount >= 1 | DNS Service restarted/stopped |
| 34 | dc-schema-update | Schema Update Detected | Medium (2) | PT5M | PT5M | EventCount >= 1 | Schema update (create/move) |
| 35 | dc-usn-rollback | USN Rollback Detected | Critical (0) | PT5M | PT5M | EventCount >= 1 | USN rollback detected |
| 36 | dc-replication-link-failure | Replication Link Failure | High (1) | PT5M | PT5M | EventCount >= 1 | Replication link failure |
| 37 | dc-rid-pool-low | RID Pool Low | High (1) | PT5M | PT5M | EventCount >= 1 | RID pool low warning |
| 38 | dc-rid-pool-exhaust | RID Pool Exhaustion | Critical (0) | PT5M | PT5M | EventCount >= 1 | RID pool exhaustion |
| 39 | dc-gc-not-advertising | GC Not Advertising | Critical (0) | PT5M | PT5M | EventCount >= 1 | Global Catalog not advertising |
| 40 | dc-dns-srv-reg-failure | DNS SRV Registration Failure | High (1) | PT5M | PT5M | EventCount >= 1 | DNS SRV registration failures |
| 41 | dc-failed-logons-burst | Failed Logons Burst | High (1) | PT5M | PT5M | Failures > failedLogonThreshold | Excessive failed logons |
| 42 | dc-account-lockout-burst | Account Lockout Burst | High (1) | PT5M | PT5M | Lockouts > accountLockoutThreshold | Account lockout spike |
| 43 | dc-sensitive-group-change | Sensitive Group Membership Change | High (1) | PT5M | PT5M | EventCount >= 1 | Privileged group membership change |
| 44 | dc-new-user-priv-change | New User Privileged Change Correlation | High (1) | PT5M | PT10M | Correlated >= 1 | New user plus privileged change |
| 45 | dc-priv-pwd-reset | Privileged Password Reset | High (1) | PT5M | PT5M | EventCount >= 1 | Privileged account password reset |
| 46 | dc-kerberos-preauth-failures | Kerberos Pre-auth Failures Burst | Medium (2) | PT5M | PT5M | Failures > kerberosPreauthFailureThreshold | Kerberos pre-auth failures burst |
| 47 | dc-lsass-high-memory | LSASS High Memory | Medium (2) | PT5M | PT15M | AvgPrivateBytes > lsassPrivateBytesThresholdBytes | LSASS private bytes high |
| 48 | dc-netlogon-secure-channel-failure | Netlogon Secure Channel Failure | Medium (2) | PT5M | PT5M | EventCount >= 1 | Secure channel setup failure |
| 49 | dc-heartbeat-missing | Heartbeat Missing >10m | High (1) | PT5M | PT15M | Missing >= 1 | No heartbeat >10m |
| 50 | dc-dfs-backlog | DFS Replication Backlog | High (1) | PT5M | PT5M | EventCount >= 1 | DFS replication backlog / journal |
| 51 | dc-gpo-processing-failure | GPO Processing Failure | Medium (2) | PT5M | PT5M | EventCount >= 1 | Group Policy processing failures |
| 52 | dc-kdc-cert-issue | KDC Certificate Issue | Medium (2) | PT5M | PT5M | EventCount >= 1 | KDC certificate issue |
| 53 | dc-schannel-errors | Schannel Errors | Medium (2) | PT5M | PT5M | EventCount >= 1 | Schannel critical errors |
| 54 | dc-ldap-insecure-bind | LDAP Insecure Bind | Medium (2) | PT5M | PT5M | EventCount >= 1 | Insecure LDAP bind attempt |

## Optional Metric Alert
| Rule Name (default) | Type | Condition | Notes |
|---------------------|------|-----------|-------|
| dc-cpu-high | Metric (Percentage CPU) | Average CPU > `cpuThreshold` over 15m (evaluated every 5m) | Only deployed if `cpuScope` (or fallback `dcResourceIds`) contains at least one VM/Arc resource ID.

## KQL Query Notes
- All event-based alerts aggregate counts over 5-minute bins (or 15-minute bins for a few informational alerts) and compare against a threshold.
- Disk space alerts use `Perf` table averaging `% Free Space` and compare the average over the window to a threshold (LessThan logic).
- Drive-specific alerts are parameterized; update `dbDriveInstanceName` and `logDriveInstanceName` in `main.parameters.json` if your AD database or logs reside on different volumes.

## Customization Guidance
1. Change severity: adjust the `severity` field for a definition in `alerts.bicep`.
2. Adjust thresholds: modify `threshold` or switch `operator` as needed.
3. Frequency & window: tune `frequency` and `window` ISO 8601 durations (e.g., `PT10M`). Keep window >= frequency.
4. Add/Remove alerts: edit the `alertDefinitions` array; maintain unique `nameSuffix` values.
5. CPU alert scope: populate `dcResourceIds` or `cpuScope` arrays in `main.parameters.json` with VM/Arc resource IDs.

## Deployment Considerations
- Scheduled Query Rules currently use preview API version `2023-12-01-preview`; consider updating to a GA version when feature parity is acceptable to reduce type warnings.
- Metric alert uses `2021-08-01`; newer versions may add features (action customization, etc.).
- Action Group is required before alert creation; the module output `actionGroupId` is injected into each alert action set.

## Maintenance Checklist
- [ ] Review preview API usage quarterly.
- [ ] Validate queries after OS / AD schema changes.
- [ ] Confirm email receivers are current (Action Group parameter).
- [ ] Adjust disk free thresholds based on capacity planning.

---
Generated documentation derived from `infra/alerts.bicep` (do not edit rule logic here—modify the Bicep file instead and regenerate docs if needed).

## Full KQL per Alert

Below are the exact KQL queries used. Replace `${dbDriveInstanceName}` / `${logDriveInstanceName}` with the actual parameter values at deployment time.

### 1. AD DB Corrupt (`dc-ad-db-corrupt`)
```
Event | where EventLog == "Directory Service" and Source == "NTDS ISAM" and EventID == 467 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 2. AD DB Disk Full (`dc-ad-disk-full`)
```
Event | where EventLog == "Directory Service" and (EventID == 1480 or RenderedDescription has "disk containing the database is full") | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 3. All Replication Partners Failing (`dc-replication-all-failing`)
```
Event | where EventLog == "Directory Service" and EventID == 1566 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 4. DC Machine Account Deleted (`dc-netlogon-machine-deleted`)
```
Event | where EventLog == "System" and Source == "NETLOGON" and EventID in (5722,5805) | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 5. DNS Zone Expired (`dc-dns-zone-expired`)
```
Event | where EventLog == "DNS Server" and EventID == 6527 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 6. DNS Zone Not Loaded (`dc-dns-zone-not-loaded`)
```
Event | where EventLog == "DNS Server" | where EventID in (4000,4007,4013) | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 7. KDC Service Not Running (`dc-kdc-service-stopped`)
```
Event | where EventLog == "System" and Source == "Service Control Manager" and EventID == 7036 and RenderedDescription has "Kerberos Key Distribution Center" | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 8. Lingering Object Detected (`dc-lingering-object`)
```
Event | where EventLog == "Directory Service" and EventID == 1988 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 9. AD DS Service Stopped (`dc-adds-service-stopped`)
```
Event | where EventLog == "System" and Source == "Service Control Manager" and EventID == 7036 and RenderedDescription has_all ("Active Directory Domain Services","stopped") | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 10. SYSVOL Unavailable (`dc-sysvol-unavailable`)
```
Event | where EventLog == "DFS Replication" and EventID == 2213 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 11. Server No Longer DC (`dc-no-longer-dc`)
```
Event | where EventLog == "Directory Service" and RenderedDescription has "no longer a domain controller" | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 12. Mutual Auth SPN Issue (`dc-mutual-auth-spn`)
```
Event | where EventLog == "Directory Service" and EventID == 1411 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 13. Replication Delayed (`dc-replication-delayed`)
```
Event | where EventLog == "Directory Service" and Source == "NTDS KCC" and EventID in (1865,1311) | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 14. DHCP Service Stopped (`dc-dhcp-service-stopped`)
```
Event | where EventLog == "System" and Source == "Service Control Manager" and EventID == 7036 and RenderedDescription has_all ("DHCP Server","stopped") | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 15. DNS Registration Failing (`dc-dns-registration-failing`)
```
Event | where EventLog == "System" and Source == "NETLOGON" | where EventID in (5774,5781) | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 16. Schema Master Bind Fail (`dc-schema-master-bind-fail`)
```
Event | where EventLog == "Directory Service" and EventID in (2091,2092) and RenderedDescription has "Schema" | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 17. GC Promotion Failed (`dc-gc-promotion-failed`)
```
Event | where EventLog == "Directory Service" and EventID in (1559,1578,1801) | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 18. Logical Disk Free Space Low (`dc-disk-free-any-low`)
```
Perf | where ObjectName == "LogicalDisk" and CounterName == "% Free Space" | where InstanceName !in ("_Total","HarddiskVolume*") | summarize AvgFreePct = avg(CounterValue) by Computer, InstanceName, bin(TimeGenerated,5m)
```

### 19. AD DB Drive Free Space Low (`dc-disk-free-db-low`)
```
Perf | where ObjectName == "LogicalDisk" and CounterName == "% Free Space" and InstanceName == "${dbDriveInstanceName}" | summarize AvgFreePct = avg(CounterValue) by Computer, bin(TimeGenerated,5m)
```

### 20. AD Log Drive Free Space Low (`dc-disk-free-log-low`)
```
Perf | where ObjectName == "LogicalDisk" and CounterName == "% Free Space" and InstanceName == "${logDriveInstanceName}" | summarize AvgFreePct = avg(CounterValue) by Computer, bin(TimeGenerated,5m)
```

### 21. NetLogon Service Stopped (`dc-netlogon-stopped`)
```
Event | where EventLog == "System" and Source == "Service Control Manager" and EventID == 7036 and RenderedDescription has "Netlogon" | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 22. Replicated Object Missing (`dc-replicated-object-missing`)
```
Event | where EventLog == "Directory Service" and EventID == 1388 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 23. Schema Change Modify (`dc-schema-change-modify`)
```
Event | where EventLog == "Security" and EventID == 5136 and RenderedDescription has "CN=Schema,CN=Configuration" | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 24. System Demotion (`dc-demotion`)
```
Event | where EventLog == "System" and Source == "LsaSrv" and EventID == 29224 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 25. Unexpected Shutdown (`dc-unexpected-shutdown`)
```
Event | where EventLog == "System" and EventID == 6008 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 26. PDC Role Change (`dc-pdc-role-change`)
```
Event | where EventLog == "Directory Service" and EventID == 1458 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 27. Time Skew Above Threshold (`dc-time-skew`)
```
Event | where EventLog == "System" and Source == "Microsoft-Windows-Time-Service" and EventID == 50 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 28. Time Sync No Sources (`dc-time-no-sources`)
```
Event | where EventLog == "System" and Source == "Microsoft-Windows-Time-Service" and EventID == 36 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 29. Time Sync Stopped (`dc-time-sync-stopped`)
```
Event | where EventLog == "System" and Source == "Microsoft-Windows-Time-Service" and EventID == 46 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 30. Server Service Stopped (`dc-lanmanserver-stopped`)
```
Event | where EventLog == "System" and Source == "Service Control Manager" and EventID == 7036 and RenderedDescription has "Server" | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 31. System Promotion (`dc-promotion`)
```
Event | where EventLog == "System" and Source == "LsaSrv" and EventID == 29223 | summarize EventCount = count() by bin(TimeGenerated,15m), Computer
```

### 32. WINS Service State Change (`dc-wins-service`)
```
Event | where EventLog == "System" and Source == "Service Control Manager" | where EventID == 7036 and RenderedDescription has "WINS" | summarize EventCount = count() by bin(TimeGenerated,15m), Computer
```

### 33. DNS Service Restarted or Stopped (`dc-dns-service-restart`)
```
Event | where EventLog == "System" and Source == "Service Control Manager" | where EventID == 7036 and RenderedDescription has "DNS Server" | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 34. Schema Update Detected (`dc-schema-update`)
```
Event | where EventLog == "Security" and EventID in (5137,5139) and RenderedDescription has "CN=Schema,CN=Configuration" | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 35. USN Rollback Detected (`dc-usn-rollback`)
```
Event | where EventLog == "Directory Service" and EventID == 2095 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 36. Replication Link Failure (`dc-replication-link-failure`)
```
Event | where EventLog == "Directory Service" and EventID == 1925 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 37. RID Pool Low (`dc-rid-pool-low`)
```
Event | where EventLog == "Directory Service" and EventID == 16645 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 38. RID Pool Exhaustion (`dc-rid-pool-exhaust`)
```
Event | where EventLog == "Directory Service" and EventID == 16654 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 39. GC Not Advertising (`dc-gc-not-advertising`)
```
Event | where EventLog == "Directory Service" and EventID == 2108 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 40. DNS SRV Registration Failure (`dc-dns-srv-reg-failure`)
```
Event | where EventLog == "Directory Service" and EventID in (2087,2088) | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 41. Failed Logons Burst (`dc-failed-logons-burst`)
```
Event | where EventLog == "Security" and EventID == 4625 | summarize Failures = count() by bin(TimeGenerated,5m), Computer
```

### 42. Account Lockout Burst (`dc-account-lockout-burst`)
```
Event | where EventLog == "Security" and EventID == 4740 | summarize Lockouts = count() by bin(TimeGenerated,5m), Computer
```

### 43. Sensitive Group Membership Change (`dc-sensitive-group-change`)
```
Event | where EventLog == "Security" and EventID in (4728,4729,4732,4733,4756,4757) | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 44. New User Privileged Change Correlation (`dc-new-user-priv-change`)
```
let Window=10m; let PrivEvents=dynamic([4728,4729,4732,4733,4756,4757]); Event | where EventLog == "Security" and EventID in (4720,4728,4729,4732,4733,4756,4757) | summarize IDs=make_set(EventID) by bin(TimeGenerated, Window), Computer | where array_index_of(IDs,4720) != -1 and array_length(set_intersection(IDs, PrivEvents)) > 0 | summarize Correlated = count() by bin(TimeGenerated, Window), Computer
```

### 45. Privileged Password Reset (`dc-priv-pwd-reset`)
```
Event | where EventLog == "Security" and EventID == 4724 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 46. Kerberos Pre-auth Failures Burst (`dc-kerberos-preauth-failures`)
```
Event | where EventLog == "Security" and EventID in (4771,4776) | summarize Failures = count() by bin(TimeGenerated,5m), Computer
```

### 47. LSASS High Memory (`dc-lsass-high-memory`)
```
Perf | where ObjectName == "Process" and CounterName == "Private Bytes" and InstanceName == "lsass" | summarize AvgPrivateBytes = avg(CounterValue) by Computer, bin(TimeGenerated,15m)
```

### 48. Netlogon Secure Channel Failure (`dc-netlogon-secure-channel-failure`)
```
Event | where EventLog == "System" and EventID == 5719 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 49. Heartbeat Missing >10m (`dc-heartbeat-missing`)
```
Heartbeat | summarize LastSeen=max(TimeGenerated) by Computer | where LastSeen < ago(10m) | summarize Missing = count() by bin(TimeGenerated,5m)
```

### 50. DFS Replication Backlog (`dc-dfs-backlog`)
```
Event | where EventLog == "DFS Replication" and EventID in (2212,2214) | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 51. GPO Processing Failure (`dc-gpo-processing-failure`)
```
Event | where EventLog == "System" and EventID in (1058,1030) | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 52. KDC Certificate Issue (`dc-kdc-cert-issue`)
```
Event | where EventLog == "System" and Source == "Kerberos-Key-Distribution-Center" and EventID == 29 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 53. Schannel Errors (`dc-schannel-errors`)
```
Event | where EventLog == "System" and Source == "Schannel" and EventID in (36882,36884) | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

### 54. LDAP Insecure Bind (`dc-ldap-insecure-bind`)
```
Event | where EventLog == "Directory Service" and EventID == 2889 | summarize EventCount = count() by bin(TimeGenerated, 5m), Computer
```

