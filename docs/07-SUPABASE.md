# 07 — Supabase

## Client keys
The iOS app only needs:

```sh
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_OR_PUBLISHABLE_KEY=your-publishable-key
```

Do not ship `SUPABASE_SERVICE_ROLE_KEY` in the app. Keep it only in server-side environments:
Supabase Edge Functions, a private backend, CI migrations, or local admin scripts.

## Current app mechanism
The app uses Supabase anonymous auth for the current "Continue" onboarding path. That creates
a real `auth.users.id` without requiring email/phone UI yet. All user data is then written
through PostgREST using the user's access token and Row Level Security.

Local JSON remains as an offline cache. When Supabase config is absent, the app continues to
run local-only.

## Required Supabase settings
Enable anonymous sign-ins in Supabase Auth before testing this app path.

## Schema
Run this SQL in Supabase SQL Editor:

```sql
create table if not exists public.households (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.households enable row level security;

grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on public.households to authenticated;
grant select, insert, update, delete on public.households to service_role;

create policy "Users can read their household"
on public.households
for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can insert their household"
on public.households
for insert
to authenticated
with check (auth.uid() = user_id);

create policy "Users can update their household"
on public.households
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_households_updated_at on public.households;
create trigger set_households_updated_at
before update on public.households
for each row execute function public.set_updated_at();
```

## Conversation persistence
Household schema v2 stores `conversations`, each with a stable ID, generated title, timestamps,
and messages. The chat shelf can therefore create, restore, and delete real threads on every
device. A legacy `chat` field is still written for compatibility, and schema-v1 payloads are
migrated into one conversation when loaded.

## Product analytics

`public.analytics_events` is a normalized, user-owned event table created by
`supabase/migrations/20260713000000_add_product_analytics.sql`. It is intentionally
separate from the household JSON because events are append-heavy and queried across time.
RLS limits authenticated clients to their own rows; client telemetry excludes names, birth
details, email, raw chat content, and Kundli payloads. See `docs/19-PRODUCT-ANALYTICS.md`
for local durability, event taxonomy, deployment, and aggregate-query examples.

## Why one `households` JSON row
The app models account, family members, patro events, conversation history, language, and theme
as one `Household` aggregate. Storing that aggregate in one user-owned JSON row keeps offline and
remote writes atomic. If analytics, sharing, search, or very large histories later require it,
split the JSON into normalized `profiles`, `family_members`, `events`, `chat_conversations`,
`chat_messages`, and `settings` tables while preserving the same `auth.uid()` ownership rule.
