# Marketing performance data

This directory stores privacy-safe aggregate data and schema contracts.

- `raw/` is append-only and contains only small, aggregate exports or metadata. Large exports stay
  in the registered Google Drive performance folder.
- `normalized/` contains analysis-ready facts at the grains defined below.
- `derived/` contains reproducible outputs generated from normalized facts.
- `schemas/` contains machine-readable contracts.

The current workspace intentionally has no fabricated performance rows. Start from the CSV files
under `marketing/templates/`, create an ingestion record, and retain the source export checksum.

## Canonical grains

| Dataset | Grain |
| --- | --- |
| Paid delivery daily | One unsegmented platform ad/publication per platform-local day and attribution setting |
| Paid breakdown daily | One publication/day/breakdown-set combination; never sum across breakdown sets |
| Organic post snapshot | One cumulative observation per publication and observation timestamp |
| Acquisition cohort snapshot | One install cohort/acquisition dimension/as-of date |
| Product events daily | One canonical event/acquisition dimension/event date aggregate |

Do not mix facts at different grains in the same file.
