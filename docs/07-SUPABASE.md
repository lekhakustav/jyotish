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

## Why one `households` JSON row
The app already models account, family members, patro events, chat history, language, and theme
as one `Household` aggregate. Storing that aggregate in one user-owned JSON row gives us a small,
safe first Supabase integration. If we later need analytics, sharing, or server-side queries, split
the JSON into normalized `profiles`, `family_members`, `events`, `chat_messages`, and `settings`
tables while keeping the same `auth.uid()` ownership rule.
