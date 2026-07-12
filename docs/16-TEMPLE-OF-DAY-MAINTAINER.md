# 16 - Temple of the Day Maintainer

## Purpose

The Temple of the Day image must follow the day's local tithi and the deity
associated with that tithi. `supabase/functions/temple-of-day-maintainer`
implements this as a server-side routine so the iOS app never needs an OpenAI
key and can simply read the public root manifest.

The maintainer keeps a seven-day rolling buffer. It skips an existing public
object, generates only missing dates, and returns a failed health status when
the contiguous buffer falls below three days.

## Selection mechanism

The function evaluates the lunar phase at the Kathmandu sunrise boundary and
selects a Nepal temple from the deity mapping below. The mapping is deliberately
explicit and auditable instead of asking the language model to choose a shrine.

| Tithi condition | Deity / observance | Temple anchor |
|---|---|---|
| Chaturthi | Ganesh | Ashok Binayak |
| Panchami | Naga | Nag Pokhari |
| Shashthi / Saptami | Surya and Ganesh | Surya Binayak |
| Ashtami | Kali | Dakshinkali |
| Navami / Dashami | Bhagwati and Kali | Gorkha Kalika |
| Ekadashi | Narayana / Vishnu | Budhanilkantha |
| Dwadashi / Trayodashi | Shiva | Pashupatinath |
| Chaturdashi | Shiva | Doleshwar |
| Krishna Aunsi | Shiva and ancestors | Gokarneshwar |
| Shukla Purnima | Buddha and illumination | Swayambhunath |
| Shukla Pratipada | Vishnu | Changu Narayan |
| Shukla Dwitiya | Bhagwati | Manakamana |
| Shukla Tritiya | Shakti and Parvati | Guhyeshwari |
| Monday override for the ordinary first ten tithis | Shiva | Pashupatinath |

The OpenAI prompt receives the selected temple, deity, setting, palette, and
tithi. It requests the app's established square, crisp-pixel Nepal devotional
style with no readable text or logos.

## Runtime contract

- Bucket: `temple-of-day`
- Root manifest: `manifest.json`
- Archive manifest: `<BS year>/manifest.json`
- Target buffer: seven contiguous dates beginning with Nepal's current date
- Health floor: three contiguous public image objects
- Image model: `gpt-image-2` by default, configurable with
  `OPENAI_TEMPLE_IMAGE_MODEL`
- Schedule: `30 18 * * *` UTC, or 00:15 the following day in Nepal Standard Time

## Deployment

Deploy the function and set its Supabase secrets as described in the function
[README](../supabase/functions/temple-of-day-maintainer/README.md). Store the
cron bearer values in Supabase Vault, apply the migration, and check
`cron.job_run_details` after the first run. No service-role key belongs in the
iOS target or in git.

For a hand-generated batch, run:

```sh
node scripts/upload-temple-assets.mjs
```

That command uploads all manifest-listed PNGs, publishes both manifests, and
performs public verification. The iOS `Temple.fetchToday()` call reads the root
manifest and keeps the local schedule as its offline fallback.
