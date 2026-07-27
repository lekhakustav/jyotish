-- The client carries only the publishable key. Ownership is enforced here.
create table if not exists public.households (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.households enable row level security;

revoke all on public.households from anon;
grant select, insert, update, delete on public.households to authenticated;
grant select, insert, update, delete on public.households to service_role;

drop policy if exists "Users can read their household" on public.households;
create policy "Users can read their household"
on public.households for select to authenticated
using (auth.uid() = user_id);

drop policy if exists "Users can insert their household" on public.households;
create policy "Users can insert their household"
on public.households for insert to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can update their household" on public.households;
create policy "Users can update their household"
on public.households for update to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
