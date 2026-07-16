# Marketing and product event taxonomy

This is the bridge between platform delivery and privacy-safe product value. The current code
already captures first-party usage events in Supabase, but acquisition context and several
funnel boundaries are not yet implemented.

## Current-state rule

`event-crosswalk.csv` records the actual iOS and Android names. Rows marked `missing` or
`derived_not_implemented` are requirements, not claims about shipped instrumentation. Reports
must not populate them until the implementation and data have been verified.

The existing legal privacy policy says the app does not collect usage analytics, while the app
currently uploads first-party product events. Reconcile the policy, store disclosures, lawful
basis, retention, access, deletion, and consent before adding attribution SDKs or paid acquisition
tracking. This taxonomy is an engineering contract, not legal approval.

## Canonical event envelope

Every future event should carry these non-content fields inside the trusted analytics system:

```text
analytics_schema_version
event_id
event_name
occurred_at_utc
session_id
install_id
platform
app_version
build_number
os_version
locale
```

When safely and lawfully available, acquisition context may add:

```text
attribution_source
attribution_model
campaign_id
creative_id
publication_id
click_window_days
view_window_days
is_modeled
```

These identifiers are pseudonymous or operational and still require protection. User-level rows,
`install_id`, `session_id`, or `user_id` never enter Git. Only aggregate cohort and event counts
belong under `marketing/data/`.

## Canonical funnel

| Stage | Canonical event | Definition |
| --- | --- | --- |
| Install | `app_first_open` | Emitted exactly once for a new local installation |
| Onboarding | `onboarding_started` | First intentional move into account/profile setup |
| Profile | `birth_profile_saved` | A valid self birth profile is persisted |
| Personalized value | `personalized_value_received` | A personalized answer or report is successfully presented |
| Activation | `activation_completed` | Derived once when profile and personalized value occur within 24 hours of first open |
| Retention | `guided_session_completed` | A later session contains at least one completed personalized answer or report |
| Monetization | `purchase_completed` | Future-only verified first-party purchase event |
| Refund | `refund_completed` | Future-only verified reversal tied to a purchase |

`activation_completed` should be derived server-side or in a trusted transformation. Clients may
emit component events, but should not independently decide that attribution or activation is
valid.

## Privacy boundary

Event properties must never contain:

- names, emails, phone numbers, account tokens, device advertising identifiers, or contact data;
- birth date, birth time, birthplace, coordinates, raw Kundali payloads, or QR payloads;
- raw chat questions, answers, voice transcripts, calendar titles, notification text, or photos;
- inferred religion, caste, health status, financial condition, or relationship verdicts.

Use stable enums such as a feature ID, intent ID, language, boolean completion flag, duration, or
bounded count. An audience strategy label belongs to the campaign registry; it is not a personal
attribute to infer and attach to a user.

## Cross-platform convergence

The long-term rule is one canonical name in both clients. During migration, the crosswalk maps
the current aliases. Transformations should preserve `source_event_name` for auditability while
reporting the canonical name. Never rewrite historical raw events.
