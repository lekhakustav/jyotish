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

Uploaded on 2026-07-06 using a service-role key in a local admin process. The
public storage bucket is `temple-of-day`; the six PNGs and `manifest.json` are
under the `2083/` prefix. Public GET verification succeeded for all PNGs with
`image/png`, and the manifest is publicly readable as `application/json`.

The app can either read `assets/temple-of-day/2083/manifest.json` at build time
or fetch the hosted manifest once the display feature is implemented:

```text
https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/2083/manifest.json
```

The intended public URL shape is:

```text
https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/2083/<filename>.png
```
