# Temple of the Day Maintainer

This trusted Edge Function keeps the public `temple-of-day` Storage bucket
populated with a rolling seven-day image buffer. Each missing day is assigned a
temple from its local Kathmandu tithi and deity association, then rendered with
the OpenAI Images API and published as a square pixel-art PNG.

## Invariants

- `TARGET_BUFFER_DAYS` is seven.
- The function reports HTTP 503 if the contiguous public buffer is below the
  three-day floor (`MIN_BUFFER_DAYS`).
- Existing public objects are skipped, so retries are idempotent.
- The root `manifest.json` is the app's runtime contract; the year-prefixed
  manifest is retained for archival and local batch tooling.

## Deploy

Set the secrets in the Supabase project, then deploy without Supabase's default
JWT gate because the function performs its own exact service-role authorization:

```sh
supabase secrets set \
  OPENAI_API_KEY=... \
  OPENAI_TEMPLE_IMAGE_MODEL=gpt-image-2 \
  OPENAI_TEMPLE_IMAGE_QUALITY=medium \
  TEMPLE_OF_DAY_SERVICE_ROLE_KEY=...
supabase functions deploy temple-of-day-maintainer --no-verify-jwt
```

`SUPABASE_URL` is supplied by the Supabase Edge runtime. The custom
`TEMPLE_OF_DAY_SERVICE_ROLE_KEY` secret is used because Supabase reserves the
`SUPABASE_*` namespace and because this project uses a newer `sb_secret_...`
key format. The key must stay in Supabase secrets or Vault. Never put it in the
iOS app, a tracked migration, or a committed shell script.

## Schedule

Migration `20260712000000_schedule_temple_of_day_maintainer.sql` schedules the
function at `30 18 * * *` UTC, which is 00:15 the following day in Nepal
Standard Time. It calls the function with a Vault-stored project URL and
service-role key. Apply the migration only after the Vault entries exist:

```sql
select vault.create_secret(
  'https://ghfcssxptpazfbtiwshz.supabase.co',
  'temple_of_day_project_url'
);
select vault.create_secret('<service-role-key>', 'temple_of_day_service_role_key');
```

Use the Supabase dashboard or CLI to inspect `cron.job_run_details`. A failed
run is visible there, and a healthy run returns JSON with `bufferDays` at least
three and normally seven.

## Local upload and verification

For a generated batch, the trusted local uploader reads `.env.local`, uploads
all manifest PNGs and both manifests, then performs public `HEAD` checks:

```sh
node scripts/upload-temple-assets.mjs
```

The script never prints credentials. The app fetches the root public manifest
and keeps its baked-in schedule as an offline fallback.
