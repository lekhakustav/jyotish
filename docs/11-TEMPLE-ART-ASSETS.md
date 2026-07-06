# 11 - Temple Art Assets

## Batch: 2026-07-06 through 2026-07-11

The first Temple of the Day art batch is staged in `assets/temple-of-day/2083/`.
These are square PNG pixel-art assets generated for the first six schedule rows in
`docs/10-TEMPLE-OF-DAY-SCHEDULE-2083.md`, excluding the earlier Manakamana preview.

| AD date | Temple | Local file | Intended Supabase path |
|---|---|---|---|
| 2026-07-06 | Pashupatinath Temple | `assets/temple-of-day/2083/2026-07-06_pashupatinath.png` | `temple-of-day/2083/2026-07-06_pashupatinath.png` |
| 2026-07-07 | Gorkha Kalika Temple | `assets/temple-of-day/2083/2026-07-07_gorkha-kalika.png` | `temple-of-day/2083/2026-07-07_gorkha-kalika.png` |
| 2026-07-08 | Dakshinkali Temple | `assets/temple-of-day/2083/2026-07-08_dakshinkali.png` | `temple-of-day/2083/2026-07-08_dakshinkali.png` |
| 2026-07-09 | Taleju Bhawani Temple | `assets/temple-of-day/2083/2026-07-09_taleju-bhawani.png` | `temple-of-day/2083/2026-07-09_taleju-bhawani.png` |
| 2026-07-10 | Budhanilkantha Temple | `assets/temple-of-day/2083/2026-07-10_budhanilkantha.png` | `temple-of-day/2083/2026-07-10_budhanilkantha.png` |
| 2026-07-11 | Budhanilkantha Temple | `assets/temple-of-day/2083/2026-07-11_budhanilkantha-yogini-ekadashi.png` | `temple-of-day/2083/2026-07-11_budhanilkantha-yogini-ekadashi.png` |

`assets/temple-of-day/2083/manifest.json` is the machine-readable contract for
the batch: date, BS date, temple id, local filename, intended storage path, and
the schedule reason.

## Supabase Upload Status

The app Supabase URL and publishable key are present in `project.yml`, but the
local `.env.local` does not contain `SUPABASE_SERVICE_ROLE_KEY`, and the Supabase
CLI is not authenticated for this account. A direct storage check on 2026-07-06
returned an empty bucket list, and creating the public `temple-of-day` bucket with
the publishable key failed with storage RLS.

To finish the upload, run it from an admin/server context with a service-role key:

1. Create a public storage bucket named `temple-of-day`.
2. Upload the six PNGs to the `2083/` paths listed above.
3. Set public-read storage policy for the bucket, or serve signed URLs from a backend.
4. Replace local image references in the app with Supabase public URLs or signed URL
   lookups once the display feature is implemented.

The intended public URL shape is:

```text
https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/2083/<filename>.png
```
