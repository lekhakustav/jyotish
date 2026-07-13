# Product analytics

This document is the implementation and operating contract for privacy-safe usage
analytics in Jyotish Baje. The goal is broad product visibility without copying
private Jyotish inputs into an analytics system.

## Guarantees

- An iOS event is appended to local storage before any upload is attempted.
- Analytics never blocks a tap, navigation transition, or chat response.
- Failed and offline uploads remain pending and retry during the same or a later run.
- Event properties must not contain names, email addresses, birth dates/times/places,
  raw chat questions, raw answers, or Kundli/chart payloads.
- The backend accepts only authenticated, user-owned rows through Row Level Security.

## Client mechanism

### iOS

`Jyotish/Services/AnalyticsService.swift` owns the analytics actor. Calls to
`AppAnalytics.track` create an event with event, session, and install UUIDs. The
event is immediately appended as JSON Lines to:

```text
Application Support/JyotishBaje/analytics-events.jsonl
```

Pending uploads are stored in `analytics-pending.json`. The append-only log rotates
at 5 MB to one `analytics-events.previous.jsonl` archive. The retry queue retains the
most recent 2,000 events and uploads authenticated batches of 100. OSLog also receives
the event name; properties are privacy-masked.

`Haptics.tap` records the common `ui_tap` event with source file, function, and line,
so existing interactive controls receive baseline click coverage without individual
boilerplate. Important flows add semantic events in `AppState`, Home, Parivar/QR,
feature discovery, chat, reminders, settings, and notification routing.

### Android / Expo

`src/analytics.ts` provides the same event envelope. Events are queued in SecureStore,
then uploaded to Supabase after authentication in batches of 100. The queue is capped
at 250 to keep the mobile store bounded. `PressableScale` records `ui_tap`; buttons
provide their visible title as the target where possible. `src/app-state.tsx` adds
semantic events for authentication, preferences, navigation, family, Patro, and chat.

## Event taxonomy

| Area | Events | Safe properties |
|---|---|---|
| Interaction | `ui_tap`, `screen_view`/`screen_viewed`, `navigation_opened`, `modal_opened`, `notification_opened` | source/target, screen, modal, destination |
| Account | `auth_started`, `auth_completed`, `auth_failed`, `auth_skipped`, `auth_signed_out`/`signed_out`, `birth_profile_saved`/`profile_saved` | provider, has_birth_data |
| Parivar | `parivar_member_added`/`family_member_added`, `parivar_member_removed`, `family_member_opened`, `parivar_qr_shown`, `parivar_qr_scanner_opened`, `parivar_qr_decoded`, `parivar_qr_decode_failed`, `parivar_qr_imported` | relation, has_birth_data, result |
| Discovery | `feature_catalog_opened`, `feature_opened`, `relationship_person_selected`, `feature_chat_started`, `pandit_opened` | feature ID, social flag, source |
| Chat | `chat_question_sent`, `chat_backend_failed`, `chat_answer_completed`, `chat_conversation_created`, `chat_conversation_selected`, `chat_conversation_deleted` | intent, language, character_count, duration_ms, source, action_count |
| Patro/notifications | `patro_event_added`, `patro_event_removed`, reminder events | repeat flag, reminder type, destination |
| Settings | `language_changed`, `theme_changed`, `notification_preference_changed`, `preference_changed` | preference, non-sensitive value |

Event names and property lengths are sanitized and bounded on the client. New events
should describe what happened, not reproduce the content involved.

## Database and RLS

Migration `supabase/migrations/20260713000000_add_product_analytics.sql` creates
`public.analytics_events`. Its primary key is `(user_id, event_id)`; time and event-name
indexes support funnel and retention queries. Authenticated users can insert, read, and
delete only their own rows. The service role can administer the table server-side.

Apply linked migrations with:

```sh
npx supabase migration list --linked
npx supabase db push --linked
```

Useful aggregate queries should be run in a trusted server/admin context:

```sql
-- Daily active installs
select occurred_at::date as day, count(distinct install_id)
from public.analytics_events
group by day order by day desc;

-- Feature discovery usage
select properties->>'feature_id' as feature, count(*)
from public.analytics_events
where event_name = 'feature_opened'
group by feature order by count(*) desc;

-- Chat completion health
select properties->>'source' as source, count(*),
       avg((properties->>'duration_ms')::numeric) as avg_duration_ms
from public.analytics_events
where event_name = 'chat_answer_completed'
group by source;
```

## Adding an event

1. Reuse an existing taxonomy name when it represents the same action.
2. Use stable IDs or enums for properties; do not send display strings or user content.
3. Add the event at the semantic action boundary, not inside a render loop.
4. Confirm offline behavior still succeeds when Supabase is unavailable.
5. Update this taxonomy when introducing a new event family.
