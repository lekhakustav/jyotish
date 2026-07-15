create table if not exists public.analytics_events (
  user_id uuid not null references auth.users(id) on delete cascade,
  event_id uuid not null,
  session_id uuid not null,
  install_id uuid not null,
  event_name text not null check (char_length(event_name) between 1 and 64),
  properties jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null,
  created_at timestamptz not null default now(),
  primary key (user_id, event_id)
);

create index if not exists analytics_events_user_time_idx
on public.analytics_events (user_id, occurred_at desc);

create index if not exists analytics_events_name_time_idx
on public.analytics_events (event_name, occurred_at desc);

alter table public.analytics_events enable row level security;

grant select, insert, delete on public.analytics_events to authenticated;
grant select, insert, update, delete on public.analytics_events to service_role;

create policy "Users can insert their analytics"
on public.analytics_events for insert to authenticated
with check (auth.uid() = user_id);

create policy "Users can read their analytics"
on public.analytics_events for select to authenticated
using (auth.uid() = user_id);

create policy "Users can delete their analytics"
on public.analytics_events for delete to authenticated
using (auth.uid() = user_id);
