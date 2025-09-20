@description('Log Analytics workspace resource ID')
param workspaceId string
@description('Action Group Resource ID for alert notifications')
param actionGroupId string
@description('Prefix for alert rule names')
param alertPrefix string = 'dc'
@description('Alert severity (0-4) for high CPU')
param cpuSeverity int = 2
@description('Average CPU percentage threshold over 15m')
param cpuThreshold int = 85
@description('LogicalDisk instance name for AD database volume (e.g. C:, D:)')
param dbDriveInstanceName string = 'C:'
@description('LogicalDisk instance name for AD log volume (e.g. C:, D:)')
param logDriveInstanceName string = 'C:'

// Additional threshold tuning parameters for extended alerts
@description('Threshold for failed logons within 5 minutes')
param failedLogonThreshold int = 20
@description('Threshold for account lockouts within 5 minutes')
param accountLockoutThreshold int = 3
@description('Threshold for Kerberos pre-auth failures within 5 minutes')
param kerberosPreauthFailureThreshold int = 25
@description('LSASS Private Bytes threshold (bytes) averaged over 15 minutes')
param lsassPrivateBytesThresholdBytes int = 6442450944 // 6 GB

// Query samples
// (Legacy sample queries removed in favor of structured alertDefinitions list.)

// Metric CPU handled via metric alert; high CPU KQL retained for future query pack if needed.

// Severity mapping for readability
var severityMap = {
  Critical: 0
  High: 1
  Medium: 2
  Low: 3
  Info: 4
}

// Common 5m count aggregation pattern
var fiveMinuteCount = '| summarize EventCount = count() by bin(TimeGenerated, 5m), Computer'

// Alert Definitions (KQL must end with aggregated column referenced by metricMeasureColumn)
var alertDefinitions = [
  {
    nameSuffix: 'ad-db-corrupt'
    displayName: 'AD DB Corrupt'
    description: 'Active Directory database is corrupt'
    severity: 'Critical'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "Directory Service" and Source == "NTDS ISAM" and EventID == 467 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'ad-disk-full'
    displayName: 'AD DB Disk Full'
    description: 'AD cannot update object because disk with database is full'
    severity: 'Critical'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "Directory Service" and (EventID == 1480 or RenderedDescription has "disk containing the database is full") ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'replication-all-failing'
    displayName: 'All Replication Partners Failing'
    description: 'All replication partners failing'
    severity: 'Critical'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "Directory Service" and EventID == 1566 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'netlogon-machine-deleted'
    displayName: 'DC Machine Account Deleted'
    description: 'DC will not start because its machine account has been deleted'
    severity: 'Critical'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "System" and Source == "NETLOGON" and EventID in (5722,5805) ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'dns-zone-expired'
    displayName: 'DNS Zone Expired'
    description: 'DNS Zone Expired'
    severity: 'Critical'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "DNS Server" and EventID == 6527 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'dns-zone-not-loaded'
    displayName: 'DNS Zone Not Loaded'
    description: 'DNS Zone Not loaded'
    severity: 'Critical'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "DNS Server" | where EventID in (4000,4007,4013) ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'kdc-service-stopped'
    displayName: 'KDC Service Not Running'
    description: 'Kerberos Key Distribution Center service stopped'
    severity: 'Critical'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "System" and Source == "Service Control Manager" and EventID == 7036 and RenderedDescription has "Kerberos Key Distribution Center" ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'lingering-object'
    displayName: 'Lingering Object Detected'
    description: 'Lingering object detected; replication blocked'
    severity: 'Critical'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "Directory Service" and EventID == 1988 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'adds-service-stopped'
    displayName: 'AD DS Service Stopped'
    description: 'AD DS service stopped'
    severity: 'Critical'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "System" and Source == "Service Control Manager" and EventID == 7036 and RenderedDescription has_all ("Active Directory Domain Services","stopped") ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'sysvol-unavailable'
    displayName: 'SYSVOL Unavailable'
    description: 'SYSVOL share is not available or accessible'
    severity: 'Critical'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "DFS Replication" and EventID == 2213 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'no-longer-dc'
    displayName: 'Server No Longer DC'
    description: 'Server no longer a domain controller'
    severity: 'Critical'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "Directory Service" and RenderedDescription has "no longer a domain controller" ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'mutual-auth-spn'
    displayName: 'Mutual Auth SPN Issue'
    description: 'Cannot construct mutual authentication SPN'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "Directory Service" and EventID == 1411 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'replication-delayed'
    displayName: 'Replication Delayed'
    description: 'Replication error / delayed'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "Directory Service" and Source == "NTDS KCC" and EventID in (1865,1311) ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'dhcp-service-stopped'
    displayName: 'DHCP Service Stopped'
    description: 'DHCP Service stopped'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "System" and Source == "Service Control Manager" and EventID == 7036 and RenderedDescription has_all ("DHCP Server","stopped") ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'dns-registration-failing'
    displayName: 'DNS Registration Failing'
    description: 'DNS registrations of essential DC records failing'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "System" and Source == "NETLOGON" | where EventID in (5774,5781) ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'schema-master-bind-fail'
    displayName: 'Schema Master Bind Fail'
    description: 'Failed to ping or bind Schema Master'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "Directory Service" and EventID in (2091,2092) and RenderedDescription has "Schema" ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'gc-promotion-failed'
    displayName: 'GC Promotion Failed'
    description: 'Failed to promote server into Global Catalog'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "Directory Service" and EventID in (1559,1578,1801) ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  // Disk space (uses AvgFreePct < threshold)
  {
    nameSuffix: 'disk-free-any-low'
    displayName: 'Logical Disk Free Space Low'
    description: 'Any logical disk free space <10%'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
    query: 'Perf | where ObjectName == "LogicalDisk" and CounterName == "% Free Space" | where InstanceName !in ("_Total","HarddiskVolume*") | summarize AvgFreePct = avg(CounterValue) by Computer, InstanceName, bin(TimeGenerated,5m)'
    metricMeasureColumn: 'AvgFreePct'
    operator: 'LessThan'
    threshold: 10
    timeAggregation: 'Average'
  }
  {
    nameSuffix: 'disk-free-db-low'
    displayName: 'AD DB Drive Free Space Low'
    description: 'DB drive free space <15%'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Perf | where ObjectName == "LogicalDisk" and CounterName == "% Free Space" and InstanceName == "${dbDriveInstanceName}" | summarize AvgFreePct = avg(CounterValue) by Computer, bin(TimeGenerated,5m)'
    metricMeasureColumn: 'AvgFreePct'
    operator: 'LessThan'
    threshold: 15
    timeAggregation: 'Average'
  }
  {
    nameSuffix: 'disk-free-log-low'
    displayName: 'AD Log Drive Free Space Low'
    description: 'Log drive free space <15%'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Perf | where ObjectName == "LogicalDisk" and CounterName == "% Free Space" and InstanceName == "${logDriveInstanceName}" | summarize AvgFreePct = avg(CounterValue) by Computer, bin(TimeGenerated,5m)'
    metricMeasureColumn: 'AvgFreePct'
    operator: 'LessThan'
    threshold: 15
    timeAggregation: 'Average'
  }
  {
    nameSuffix: 'netlogon-stopped'
    displayName: 'NetLogon Service Stopped'
    description: 'NetLogon service not running'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "System" and Source == "Service Control Manager" and EventID == 7036 and RenderedDescription has "Netlogon" ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'replicated-object-missing'
    displayName: 'Replicated Object Missing'
    description: 'Replicated object missing may be garbage collected'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "Directory Service" and EventID == 1388 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'schema-change-modify'
    displayName: 'Schema Change Modify'
    description: 'Schema modify event'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "Security" and EventID == 5136 and RenderedDescription has "CN=Schema,CN=Configuration" ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'demotion'
    displayName: 'System Demotion'
    description: 'Domain controller demotion'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "System" and Source == "LsaSrv" and EventID == 29224 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'unexpected-shutdown'
    displayName: 'Unexpected Shutdown'
    description: 'Domain Controller unexpected shutdown'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "System" and EventID == 6008 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'pdc-role-change'
    displayName: 'PDC Role Change'
    description: 'Server promoted to PDC Emulator'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "Directory Service" and EventID == 1458 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'time-skew'
    displayName: 'Time Skew Above Threshold'
    description: 'Time skew above configured threshold'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "System" and Source == "Microsoft-Windows-Time-Service" and EventID == 50 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'time-no-sources'
    displayName: 'Time Sync No Sources'
    description: 'Time sync – no time sources'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "System" and Source == "Microsoft-Windows-Time-Service" and EventID == 36 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'time-sync-stopped'
    displayName: 'Time Sync Stopped'
    description: 'Time Sync stopped'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "System" and Source == "Microsoft-Windows-Time-Service" and EventID == 46 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'lanmanserver-stopped'
    displayName: 'Server Service Stopped'
    description: 'Windows Server Service stopped'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "System" and Source == "Service Control Manager" and EventID == 7036 and RenderedDescription has "Server" ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'promotion'
    displayName: 'System Promotion'
    description: 'Domain controller promotion (Info)'
    severity: 'Info'
    frequency: 'PT5M'
    window: 'PT15M'
    query: 'Event | where EventLog == "System" and Source == "LsaSrv" and EventID == 29223 | summarize EventCount = count() by bin(TimeGenerated,15m), Computer'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'wins-service'
    displayName: 'WINS Service State Change'
    description: 'WINS service state change'
    severity: 'Low'
    frequency: 'PT5M'
    window: 'PT15M'
    query: 'Event | where EventLog == "System" and Source == "Service Control Manager" | where EventID == 7036 and RenderedDescription has "WINS" | summarize EventCount = count() by bin(TimeGenerated,15m), Computer'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'dns-service-restart'
    displayName: 'DNS Service Restarted or Stopped'
    description: 'DNS Service restarted / stopped'
    severity: 'Medium'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "System" and Source == "Service Control Manager" | where EventID == 7036 and RenderedDescription has "DNS Server" ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'schema-update'
    displayName: 'Schema Update Detected'
    description: 'Schema update (create/move)'
    severity: 'Medium'
    frequency: 'PT5M'
    window: 'PT5M'
  query: 'Event | where EventLog == "Security" and EventID in (5137,5139) and RenderedDescription has "CN=Schema,CN=Configuration" ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }

  // --- Additional Alerts ---
  // Critical / High replication & directory health
  {
    nameSuffix: 'usn-rollback'
    displayName: 'USN Rollback Detected'
    description: 'USN rollback detected (EventID 2095)'
    severity: 'Critical'
    frequency: 'PT5M'
    window: 'PT5M'
    query: 'Event | where EventLog == "Directory Service" and EventID == 2095 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'replication-link-failure'
    displayName: 'Replication Link Failure'
    description: 'Replication link failure (EventID 1925)'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
    query: 'Event | where EventLog == "Directory Service" and EventID == 1925 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'rid-pool-low'
    displayName: 'RID Pool Low'
    description: 'RID pool low warning (EventID 16645)'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
    query: 'Event | where EventLog == "Directory Service" and EventID == 16645 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'rid-pool-exhaust'
    displayName: 'RID Pool Exhaustion'
    description: 'RID pool exhaustion (EventID 16654)'
    severity: 'Critical'
    frequency: 'PT5M'
    window: 'PT5M'
    query: 'Event | where EventLog == "Directory Service" and EventID == 16654 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'gc-not-advertising'
    displayName: 'GC Not Advertising'
    description: 'Global Catalog not advertising (EventID 2108)'
    severity: 'Critical'
    frequency: 'PT5M'
    window: 'PT5M'
    query: 'Event | where EventLog == "Directory Service" and EventID == 2108 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'dns-srv-reg-failure'
    displayName: 'DNS SRV Registration Failure'
    description: 'DNS SRV registration failures (2087/2088)'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
    query: 'Event | where EventLog == "Directory Service" and EventID in (2087,2088) ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }

  // Security / authentication bursts
  {
    nameSuffix: 'failed-logons-burst'
    displayName: 'Failed Logons Burst'
    description: 'Excessive failed logons (4625)'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
    query: 'Event | where EventLog == "Security" and EventID == 4625 | summarize Failures = count() by bin(TimeGenerated,5m), Computer'
    metricMeasureColumn: 'Failures'
    operator: 'GreaterThan'
    threshold: failedLogonThreshold
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'account-lockout-burst'
    displayName: 'Account Lockout Burst'
    description: 'Account lockout spike (4740)'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
    query: 'Event | where EventLog == "Security" and EventID == 4740 | summarize Lockouts = count() by bin(TimeGenerated,5m), Computer'
    metricMeasureColumn: 'Lockouts'
    operator: 'GreaterThan'
    threshold: accountLockoutThreshold
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'sensitive-group-change'
    displayName: 'Sensitive Group Membership Change'
    description: 'Privileged group membership change (4728/4729/4732/4733/4756/4757)'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
    query: 'Event | where EventLog == "Security" and EventID in (4728,4729,4732,4733,4756,4757) ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'new-user-priv-change'
    displayName: 'New User Privileged Change Correlation'
    description: 'New user creation followed by privileged group change within 10m'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT10M'
  query: 'let Window=10m; let PrivEvents=dynamic([4728,4729,4732,4733,4756,4757]); Event | where EventLog == "Security" and EventID in (4720,4728,4729,4732,4733,4756,4757) | summarize hasCreate = any(EventID == 4720), hasPriv = any(EventID in (4728,4729,4732,4733,4756,4757)) by bin(TimeGenerated, Window), Computer | where hasCreate and hasPriv | project TimeGenerated, Computer, Correlated=1 | summarize Correlated = count() by bin(TimeGenerated, Window), Computer'
    metricMeasureColumn: 'Correlated'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'priv-pwd-reset'
    displayName: 'Privileged Password Reset'
    description: 'Password reset event (4724)'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
    query: 'Event | where EventLog == "Security" and EventID == 4724 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'kerberos-preauth-failures'
    displayName: 'Kerberos Pre-auth Failures Burst'
    description: 'Kerberos pre-auth failures (4771/4776)'
    severity: 'Medium'
    frequency: 'PT5M'
    window: 'PT5M'
    query: 'Event | where EventLog == "Security" and EventID in (4771,4776) | summarize Failures = count() by bin(TimeGenerated,5m), Computer'
    metricMeasureColumn: 'Failures'
    operator: 'GreaterThan'
    threshold: kerberosPreauthFailureThreshold
    timeAggregation: 'Count'
  }

  // Performance / service health
  {
    nameSuffix: 'lsass-high-memory'
    displayName: 'LSASS High Memory'
    description: 'LSASS private bytes high'
    severity: 'Medium'
    frequency: 'PT5M'
    window: 'PT15M'
    query: 'Perf | where ObjectName == "Process" and CounterName == "Private Bytes" and InstanceName == "lsass" | summarize AvgPrivateBytes = avg(CounterValue) by Computer, bin(TimeGenerated,15m)'
    metricMeasureColumn: 'AvgPrivateBytes'
    operator: 'GreaterThan'
    threshold: lsassPrivateBytesThresholdBytes
    timeAggregation: 'Average'
  }
  {
    nameSuffix: 'netlogon-secure-channel-failure'
    displayName: 'Netlogon Secure Channel Failure'
    description: 'Secure channel setup failure (5719)'
    severity: 'Medium'
    frequency: 'PT5M'
    window: 'PT5M'
    query: 'Event | where EventLog == "System" and EventID == 5719 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'heartbeat-missing'
    displayName: 'Heartbeat Missing >10m'
    description: 'No heartbeat in last 10 minutes'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT15M'
  query: 'Heartbeat | summarize LastSeen=max(TimeGenerated) by Computer | where LastSeen < ago(10m) | extend TimeGenerated=LastSeen | summarize Missing = count() by bin(TimeGenerated,5m), Computer'
    metricMeasureColumn: 'Missing'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'dfs-backlog'
    displayName: 'DFS Replication Backlog'
    description: 'DFS replication backlog / journal (2212/2214)'
    severity: 'High'
    frequency: 'PT5M'
    window: 'PT5M'
    query: 'Event | where EventLog == "DFS Replication" and EventID in (2212,2214) ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'gpo-processing-failure'
    displayName: 'GPO Processing Failure'
    description: 'Group Policy processing failures (1058/1030)'
    severity: 'Medium'
    frequency: 'PT5M'
    window: 'PT5M'
    query: 'Event | where EventLog == "System" and EventID in (1058,1030) ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'kdc-cert-issue'
    displayName: 'KDC Certificate Issue'
    description: 'KDC certificate issue (EventID 29)'
    severity: 'Medium'
    frequency: 'PT5M'
    window: 'PT5M'
    query: 'Event | where EventLog == "System" and Source == "Kerberos-Key-Distribution-Center" and EventID == 29 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'schannel-errors'
    displayName: 'Schannel Errors'
    description: 'Schannel critical errors (36882/36884)'
    severity: 'Medium'
    frequency: 'PT5M'
    window: 'PT5M'
    query: 'Event | where EventLog == "System" and Source == "Schannel" and EventID in (36882,36884) ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
  {
    nameSuffix: 'ldap-insecure-bind'
    displayName: 'LDAP Insecure Bind'
    description: 'Insecure LDAP bind attempt (EventID 2889)'
    severity: 'Medium'
    frequency: 'PT5M'
    window: 'PT5M'
    query: 'Event | where EventLog == "Directory Service" and EventID == 2889 ${fiveMinuteCount}'
    metricMeasureColumn: 'EventCount'
    operator: 'GreaterThanOrEqual'
    threshold: 1
    timeAggregation: 'Count'
  }
]

// Scheduled Query Rules loops split to handle Count vs other aggregations (metricMeasureColumn forbidden with Count)
resource logAlertsCount 'Microsoft.Insights/scheduledQueryRules@2023-12-01' = [for def in alertDefinitions: if (def.timeAggregation == 'Count') {
  name: '${alertPrefix}-${def.nameSuffix}'
  location: resourceGroup().location
  properties: {
    displayName: def.displayName
    description: def.description
    severity: severityMap[def.severity]
    enabled: true
    evaluationFrequency: def.frequency
    windowSize: def.window
    scopes: [ workspaceId ]
    criteria: {
      allOf: [
        {
          query: def.query
          timeAggregation: def.timeAggregation
          operator: def.operator
          threshold: def.threshold
          dimensions: []
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    actions: {
      actionGroups: [ actionGroupId ]
    }
    autoMitigate: true
  }
  tags: {
    solution: 'dc-monitor'
    category: 'ad-domain-controller'
  }
}]

resource logAlertsMetric 'Microsoft.Insights/scheduledQueryRules@2023-12-01' = [for def in alertDefinitions: if (def.timeAggregation != 'Count') {
  name: '${alertPrefix}-${def.nameSuffix}'
  location: resourceGroup().location
  properties: {
    displayName: def.displayName
    description: def.description
    severity: severityMap[def.severity]
    enabled: true
    evaluationFrequency: def.frequency
    windowSize: def.window
    scopes: [ workspaceId ]
    criteria: {
      allOf: [
        {
          query: def.query
          timeAggregation: def.timeAggregation
          metricMeasureColumn: def.metricMeasureColumn
          operator: def.operator
          threshold: def.threshold
          dimensions: []
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    actions: {
      actionGroups: [ actionGroupId ]
    }
    autoMitigate: true
  }
  tags: {
    solution: 'dc-monitor'
    category: 'ad-domain-controller'
  }
}]

@description('Optional: List of VM/Arc machine resource IDs for CPU metric alert')
param cpuScope array = []

resource cpuAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = if (length(cpuScope) > 0) {
  name: '${alertPrefix}-cpu-high'
  location: resourceGroup().location
  properties: {
    description: 'Domain Controller high average CPU'
    severity: cpuSeverity
    enabled: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    autoMitigate: true
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'HighCPU'
          metricName: 'Percentage CPU'
          metricNamespace: 'Microsoft.Compute/virtualMachines'
          operator: 'GreaterThan'
          threshold: cpuThreshold
          timeAggregation: 'Average'
          dimensions: []
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    scopes: cpuScope
    actions: [
      {
        actionGroupId: actionGroupId
      }
    ]
  }
  tags: {
    solution: 'dc-monitor'
  }
}

// Output the IDs via resourceId reconstruction (collection direct reference unsupported in output)
output scheduledQueryAlertIds array = [for def in alertDefinitions: resourceId('Microsoft.Insights/scheduledQueryRules', '${alertPrefix}-${def.nameSuffix}')]
output cpuAlertId string = length(cpuScope) > 0 ? cpuAlert.id : ''
