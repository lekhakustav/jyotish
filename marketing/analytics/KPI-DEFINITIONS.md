# Marketing KPI definitions

This document is the calculation contract for marketing reports. The formulas are also
registered in `metrics.csv`; reports must use those definitions rather than silently inventing
new denominators.

## Measurement hierarchy

Jyotish Baje is currently free. The active business outcome is therefore an activated household,
not a payer or ROAS. Revenue metrics remain registered as future-only fields so the schema will
not need to be redesigned when monetization is intentionally added.

An install is **activated in D1** when the same pseudonymous install:

1. records `app_first_open`,
2. saves a birth profile, and
3. receives a completed personalized Baje answer or completed personalized report

within 24 hours of first open. Until `app_first_open` and a canonical personalized-value event
exist on both platforms, activation must be reported as unavailable or as a clearly labelled
proxy. It must not be fabricated from platform clicks.

The north-star product measure is **weekly guided households**: distinct households that receive
a completed personalized answer or report during the reporting week. Only aggregate counts may
leave the trusted product analytics environment.

## Symbols and formulas

Let:

- `I` = impressions
- `R` = reach
- `S` = video starts
- `V2` / `V3` = native two-second / three-second views
- `Q100` = 100 percent video plays
- `W` = total watch time in seconds
- `OC` = outbound clicks
- `LPV` = landing-page views
- `N` = attributed installs
- `A` = activated installs
- `P` = new payers

| KPI | Formula | Interpretation |
| --- | --- | --- |
| CPM | `1000 * spend / I` | Media cost per thousand impressions |
| Frequency | `I / R` | Average impressions per reached account |
| Start rate | `S / I` | How often an impression becomes a video start |
| Two-second view rate | `V2 / I` | Platform-native early hold diagnostic |
| Three-second view rate | `V3 / I` | Platform-native early hold diagnostic |
| Completion rate | `Q100 / S` | Completion conditional on starting |
| Completion per impression | `Q100 / I` | Completed plays per delivered impression |
| Average watch seconds | `W / S` | Watch time conditional on a start |
| Normalized watch ratio | `(W / S) / creative_duration_seconds` | Length-normalized watch; may exceed 1 because of loops |
| Engagement rate | `(likes + comments + shares + saves) / I` | Broad interaction rate |
| Quality engagement rate | `(shares + saves) / I` | Higher-intent distribution and utility signal |
| Shares per 1,000 | `1000 * shares / I` | Share intensity |
| Save rate | `saves / I` | Reported saves per impression; null when saves are unavailable |
| Comment rate | `comments / I` | All reported comments per impression; not a qualified-comment measure |
| Outbound CTR | `OC / I` | Movement from platform toward the destination |
| Landing rate | `LPV / OC` | Destination load after an outbound click |
| Click-to-install rate | `click_attributed_installs / OC` | Click-attributed install conversion |
| Installs per 1,000 | `1000 * N / I` | Acquisition efficiency independent of spend |
| CPI | `spend / N` | Cost per attributed install |
| D1 activation rate | `A / eligible_D1_installs` | Product value reached within 24 hours |
| Cost per activated install | `spend / A` | Launch-stage acquisition outcome |
| CAC | `spend / P` | Future-only cost per first payer |
| ROAS | `attributed_net_revenue / spend` | Future-only attributed revenue efficiency |

When a denominator is zero or unavailable, the result is null. It is never zero or infinity.
Missing source fields remain null; zero means the platform explicitly reported zero.

## Launch feature metrics

The launch creative matrix uses these feature-specific secondary metrics. They are registered now
so future reports cannot change the denominator after seeing results, but they remain blocked
until the named event and attribution prerequisites are real.

| Metric key | Exact definition | Current availability |
| --- | --- | --- |
| `profile_save_to_first_answer_rate` | Unique installs with `chat_answer_completed` within 24 hours after `birth_profile_saved`, divided by unique installs with `birth_profile_saved` | Blocked: canonical ordered funnel export is missing; creative-level use also needs attribution |
| `kundali_detail_open_rate` | Unique eligible installs with `kundali_detail_opened`, divided by eligible installs | Blocked: no dedicated event; `family_member_opened` is not an exact substitute |
| `dasha_report_start_rate` | Unique attributed installs with `feature_chat_started` and `feature=lifePhase`, divided by eligible attributed installs | Blocked: feature event exists; attribution does not |
| `muhurat_report_start_rate` | Unique attributed installs with `feature_chat_started` and `feature=muhurta`, divided by eligible attributed installs | Blocked: feature event exists; attribution does not |
| `matching_report_start_rate` | Unique attributed installs with `feature_chat_started` and `feature=kundliMatching`, divided by eligible attributed installs | Blocked: feature event exists; attribution does not |
| `voice_input_start_rate` | Unique attributed installs with `voice_input_started`, divided by eligible attributed installs | Blocked: event and attribution are missing |
| `qr_open_to_import_rate` | Unique sessions with `parivar_qr_imported` after a receive/scan open, divided by unique sessions with a receive/scan open | Blocked: iOS/Android event boundaries and names differ |
| `family_profile_to_answer_rate` | Unique sessions completing an answer in the same selected-family context after `relationship_person_selected`, divided by sessions with `relationship_person_selected` | Blocked: completed-answer events do not consistently retain family/feature context |
| `panchang_report_start_rate` | Unique attributed installs with `feature_chat_started` and `feature=panchang`, divided by eligible attributed installs | Blocked: feature event exists; attribution does not |
| `birth_profile_saved_rate` | Unique attributed installs with `birth_profile_saved` within 24 hours, divided by eligible attributed installs | Blocked: first-open boundary, canonical aliasing, and attribution are missing |

An "eligible attributed install" means an install inside the pre-registered attribution and
measurement windows after exclusions. Until that cohort exists, these values are null. Do not
substitute platform clicks, raw event counts, or a hand-picked denominator.

## Retention windows

Retention uses elapsed windows from `app_first_open`, not a mix of platform time zones:

- D1: at least one qualifying personalized-value event from 24 through less than 48 hours.
- D7: at least one qualifying event from 168 through less than 192 hours.
- D30: at least one qualifying event from 720 through less than 744 hours.

Only cohorts old enough to complete the window belong in the denominator. Every cohort export
records an `as_of_date` so delayed attribution and retention maturity remain visible.

## Comparability rules

- Meta three-second views and TikTok two-second views are not one universal "hook rate." Compare
  native definitions within a platform or use separately named metrics.
- Paid delivery rows are daily flows. Organic post observations are cumulative snapshots. Never
  sum organic snapshots.
- Click-through, view-through, SKAN, and modeled conversions remain separate fields.
- Platform-reported attribution is not deterministic ground truth. The attribution model and
  click/view windows must accompany every conversion report.
- Paid and organic performance have different delivery mechanisms and cannot be pooled as one
  experiment.
- Platform age buckets do not exactly represent the documented 40--80 product audience. Report
  the original buckets and avoid reconstructing unsupported precision.

## Statistical decision contract

- One pre-registered primary metric per experiment.
- Use platform-native split tests for causal claims. Ordinary optimized ad delivery and organic
  posting are observational.
- Plan sample size from a baseline and a minimum useful effect. Do not declare a winner from an
  arbitrary impression count.
- Run at least one complete seven-day cycle unless a pre-registered safety or spend stop fires.
- Do not repeatedly peek at a fixed-horizon significance test.
- Use Wilson intervals for rates. For cost and revenue, bootstrap at the day/ad cluster rather
  than pretending impressions are independent observations.
- Apply Benjamini--Hochberg correction to exploratory metric families.
- Test subgroup interactions directly; significance in one age group and not another does not
  itself demonstrate a difference between groups.
- Record budget, audience, placement, copy, and status changes in
  `registry/operational-changes.csv` because they can invalidate a comparison.

"Viral" is a descriptive outcome relative to the account's own history, not a universal view
threshold. A report may label a post provisionally viral only when its reach velocity and share
rate are both exceptional against a documented historical comparison set.
