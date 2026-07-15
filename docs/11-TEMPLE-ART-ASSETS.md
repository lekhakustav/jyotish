# 11 - Temple Art Assets

## Batch: 2026-07-06 through 2026-07-17

Temple of the Day assets are staged in `assets/temple-of-day/2083/`. They are
square PNG pixel-art assets selected from the tithi/deity schedule in
`docs/10-TEMPLE-OF-DAY-SCHEDULE-2083.md`.

| AD date | Temple | Local file | Intended Supabase path |
|---|---|---|---|
| 2026-07-06 | Pashupatinath Temple | `assets/temple-of-day/2083/2026-07-06_pashupatinath.png` | `temple-of-day/2083/2026-07-06_pashupatinath.png` |
| 2026-07-07 | Gorkha Kalika Temple | `assets/temple-of-day/2083/2026-07-07_gorkha-kalika.png` | `temple-of-day/2083/2026-07-07_gorkha-kalika.png` |
| 2026-07-08 | Dakshinkali Temple | `assets/temple-of-day/2083/2026-07-08_dakshinkali.png` | `temple-of-day/2083/2026-07-08_dakshinkali.png` |
| 2026-07-09 | Taleju Bhawani Temple | `assets/temple-of-day/2083/2026-07-09_taleju-bhawani.png` | `temple-of-day/2083/2026-07-09_taleju-bhawani.png` |
| 2026-07-10 | Budhanilkantha Temple | `assets/temple-of-day/2083/2026-07-10_budhanilkantha.png` | `temple-of-day/2083/2026-07-10_budhanilkantha.png` |
| 2026-07-11 | Budhanilkantha Temple | `assets/temple-of-day/2083/2026-07-11_budhanilkantha-yogini-ekadashi.png` | `temple-of-day/2083/2026-07-11_budhanilkantha-yogini-ekadashi.png` |
| 2026-07-12 | Pashupatinath Temple | `assets/temple-of-day/2083/2026-07-12_pashupatinath-pradosh.png` | `temple-of-day/2083/2026-07-12_pashupatinath-pradosh.png` |
| 2026-07-13 | Pashupatinath Temple | `assets/temple-of-day/2083/2026-07-13_pashupatinath-bhanu-jayanti.png` | `temple-of-day/2083/2026-07-13_pashupatinath-bhanu-jayanti.png` |
| 2026-07-14 | Gokarneshwar Mahadev Temple | `assets/temple-of-day/2083/2026-07-14_gokarneshwar-aunsi.png` | `temple-of-day/2083/2026-07-14_gokarneshwar-aunsi.png` |
| 2026-07-15 | Changu Narayan Temple | `assets/temple-of-day/2083/2026-07-15_changu-narayan-pratipada.png` | `temple-of-day/2083/2026-07-15_changu-narayan-pratipada.png` |
| 2026-07-16 | Manakamana Temple | `assets/temple-of-day/2083/2026-07-16_manakamana-dwitiya.png` | `temple-of-day/2083/2026-07-16_manakamana-dwitiya.png` |
| 2026-07-17 | Guhyeshwari Shakti Peeth | `assets/temple-of-day/2083/2026-07-17_guhyeshwari-tritiya.png` | `temple-of-day/2083/2026-07-17_guhyeshwari-tritiya.png` |

`assets/temple-of-day/2083/manifest.json` is the machine-readable contract for
the batch: date, BS date, temple id, local filename, intended storage path, and
the schedule reason.

## Supabase Upload Status

The public storage bucket is `temple-of-day`. The local uploader uploads every
PNG listed in the manifest plus both `2083/manifest.json` and the runtime root
`manifest.json`, then verifies every public object with `HEAD`.

For the rolling production path, see
[`docs/16-TEMPLE-OF-DAY-MAINTAINER.md`](16-TEMPLE-OF-DAY-MAINTAINER.md). The
deployed maintainer generates missing days from the tithi/deity mapping and
targets seven contiguous days, with a three-day minimum health threshold.

The app fetches the hosted root manifest at runtime and uses its baked-in
schedule when the network is unavailable:

```text
https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/manifest.json
```

The year-prefixed manifest remains available for batch inspection:

```text
https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/2083/manifest.json
```

The intended public URL shape is:

```text
https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/2083/<filename>.png
```
