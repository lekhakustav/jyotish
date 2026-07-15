-- Temple of the Day is kept seven days ahead by a trusted Edge Function.
-- The project URL and service-role key are stored in Vault, never in git.

create extension if not exists pg_cron with schema pg_catalog;
create extension if not exists pg_net;

select cron.unschedule(jobid)
from cron.job
where jobname = 'temple-of-day-daily';

select cron.schedule(
  'temple-of-day-daily',
  '30 18 * * *',
  $$
  select net.http_post(
    url := (select decrypted_secret from vault.decrypted_secrets where name = 'temple_of_day_project_url')
      || '/functions/v1/temple-of-day-maintainer',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || (select decrypted_secret from vault.decrypted_secrets where name = 'temple_of_day_service_role_key')
    ),
    body := jsonb_build_object('scheduledAt', now())
  );
  $$
);
