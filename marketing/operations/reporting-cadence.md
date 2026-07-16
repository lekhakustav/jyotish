# Marketing reporting cadence

All reporting uses Nepal time (`Asia/Kathmandu`) for the operating schedule while preserving each
platform account's source time zone in the data.

## Launch and daily operations

| Timing | Purpose | Permitted decision |
| --- | --- | --- |
| Before launch | Link, destination, publication ID, caption, audio, crop, claims, and experiment-plan QA | Launch or hold |
| Launch + 2 hours | Confirm delivery, spend, playable media, destination, and obvious attribution failures | Technical repair only |
| Daily at 09:00 NPT | Ingest prior-day exports, validate, label maturity, and annotate operational changes | No casual winner declaration |
| 72 hours | Provisional creative diagnostics when the plan has sufficient data | Continue, safety stop, or pre-registered futility action |
| At pre-registered horizon | Primary analysis after the required duration/sample and attribution lag | Scale, iterate, hold, stop, or inconclusive |

Do not edit live treatments merely because an early secondary metric fluctuates. Any necessary
budget, targeting, placement, caption, status, or destination change goes into
`registry/operational-changes.csv` with its likely experiment impact.

## Weekly report

Publish one report for a Sunday-through-Saturday operating week after the prior week has its
declared data lag. Use `templates/weekly-report.md`. It must contain:

1. data cutoff, maturity labels, attribution windows, source export IDs, and analysis commit;
2. spend and delivery integrity;
3. creative diagnostics by concept and factor;
4. acquisition and activation only where instrumentation is valid;
5. experiment status and decisions;
6. audience/placement heterogeneity without unsupported causal claims;
7. fatigue, anomalies, missing data, and operational interventions;
8. exact next tests and what they are intended to teach.

## Monthly report

Once cohorts mature, review D1/D7/D30 guided retention, concept-family performance, audience role,
language, market, creative fatigue, and—in a future monetized product—unit economics. Separate
current-period delivery from cohort outcomes so recently acquired users do not depress mature
retention mechanically.

## Report provenance

Every report records:

```text
data_cutoff_utc
data_maturity
source_export_ids
input_hashes
analysis_script_git_sha
platform_account_timezones
attribution_models_and_windows
known_data_issues
operational_changes
decision
next_experiments
```

Reports are append-only evidence. Correct a material error with a dated amendment that explains
the changed inputs and decision impact.
