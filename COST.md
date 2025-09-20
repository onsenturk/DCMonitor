# Cost Overview

This document summarizes estimated monthly costs for the current Domain Controller monitoring setup (Log Analytics + Data Collection Rule + ~54 scheduled query alerts + optional CPU metric alert + Action Group) and provides levers to tune spend.

> All figures are illustrative. Always validate with the Azure Pricing page for your region (Sweden Central assumed) and measure actual ingestion via the `Usage` table after 24–48 hours.

## Components
- Log Ingestion (Windows Event Logs + Perf counters)
- Retention beyond included 31 days (you configured 90)
- Scheduled Query (Log) Alert Executions (~54 rules @ 5m cadence)
- Metric Alert (CPU – optional, usually small)
- Action Group (email notifications – free)

## Assumed Unit Prices (Illustrative)
- Ingestion: ~$2.76 / GB
- Additional Retention (days > 31): ~$0.12 / GB-month
- Log Alert Executions: $0.10–$0.15 per 1,000 evaluations
- Metric Alert (1 multi-resource): ~ $1 / month upper bound

## Core Formulas
```
DailyIngestAllGB = DailyIngestPerDCGB * NumberOfDCs
MonthlyIngestGB  = DailyIngestAllGB * 30
IngestionCost    = MonthlyIngestGB * IngestionRate
AgedGB (retention>31) = DailyIngestAllGB * (RetentionDays - 31)
RetentionCost    = AgedGB * RetentionRate
AlertExecsPerDay = RuleCount * (1440 / FrequencyMinutes)
MonthlyAlertExecs= AlertExecsPerDay * 30
LogAlertCost     = (MonthlyAlertExecs / 1000) * AlertExecRate
TotalCost ≈ IngestionCost + RetentionCost + LogAlertCost + MetricAlertCost
```

Parameters currently:
- RuleCount = 54
- FrequencyMinutes = 5
- RetentionDays = 90

## Scenario Summary (10 Domain Controllers)
Daily ingestion per DC drives cost most. Three volume tiers:

| Scenario  | Ingestion $ | Retention $ | Log Alerts $ | Metric $ | Total Monthly $ | Per DC $ |
|-----------|-------------|-------------|--------------|----------|-----------------|----------|
| Low (0.06 GB/day/DC)      | 49.7        | 4.25        | 46.7–70.0    | ~1       | 101.7–124.9     | 10.2–12.5 |
| Moderate (0.25 GB/day/DC) | 207         | 17.7        | 46.7–70.0    | ~1       | 272.4–295.7     | 27.2–29.6 |
| High (0.75 GB/day/DC)     | 621         | 53.1        | 46.7–70.0    | ~1       | 721.8–745.1     | 72.2–74.5 |

Notes:
- Ingestion scales linearly with event volume/auditing depth.
- Alert execution cost is fixed unless you reduce rule count or cadence.
- Retention cost becomes more material at higher ingestion levels.

## Measuring Actual Ingestion
Run in Log Analytics after ~24h:
```kusto
Usage
| where TimeGenerated > ago(24h)
| summarize GB=sum(Quantity)/1024 by DataType
| order by GB desc
```
Total daily GB:
```kusto
Usage
| where TimeGenerated > ago(24h)
| summarize TotalGB=sum(Quantity)/1024
```

Security log driver:
```kusto
Event
| where EventLog == "Security" and TimeGenerated > ago(24h)
| summarize Events=count()
```

## Cost Optimization Levers (Priority Order)
1. Reduce alert executions: increase evaluation frequency for non-critical alerts (5m -> 10/15m) or consolidate multiple single-ID rules.
2. Filter event collection: Replace broad `Channel!*` with XPath filters targeting required Event IDs/categories after baseline.
3. Table-level retention tuning: Keep Security 90 days; reduce others if feasible.
4. Narrow perf counters: Scope disk counters to specific drive letters; keep only essential process counters.
5. Daily quota (optional safeguard): Add `workspaceCapping.dailyQuotaGb`.

## Optional: Daily Quota Snippet
Add to `log-analytics.bicep` resource properties (adjust value):
```bicep
properties: {
  retentionInDays: retentionInDays
  features: {
    enableLogAccessUsingOnlyResourcePermissions: true
  }
  workspaceCapping: {
    dailyQuotaGb: 5
  }
}
```

## Quick Recalculation Cheat Sheet
```
# After measuring daily actual ingestion:
TotalMonthly = (DailyGB * 30 * 2.76) \
             + (DailyGB * 59 * 0.12) \
             + ((54 * (1440/5) * 30)/1000 * 0.12) \
             + 1
```
(Adjust the 0.12 alert exec rate to your observed billing rate.)

## When to Revisit
- After enabling additional auditing categories
- Adding more Domain Controllers
- Increasing retention or adding new perf counters
- Introducing new alert sets (security correlation, replication depth)

---
**Action Recommendation:** Measure real ingestion for a week, pick a target (e.g., keep total < Moderate mid-range), then tune alerts & DCR filters accordingly.
