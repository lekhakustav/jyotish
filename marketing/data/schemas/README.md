# Marketing schemas

- `csv-contracts.json` is the executable header, type, enum, primary-key, and foreign-key
  contract used by `npm run marketing:validate`.
- `experiment-plan.schema.json` validates every real `marketing/experiments/*/plan.json`.
- `experiment-amendment.schema.json` defines one line of an experiment `amendments.jsonl` file.
- `veo-prompt.schema.json` defines a structured scene prompt plus post-production recipe.
- `performance-rows.schema.json` documents the normalized paid, organic, cohort, and product-event
  facts represented by the CSV templates.
- `report-metadata.schema.json` defines reproducibility metadata for generated reports.

Schemas use JSON Schema draft 2020-12 where practical. `csv-contracts.json` is a small explicit
contract format because CSV headers, composite keys, and cross-file foreign keys are not naturally
expressed as standalone JSON Schema.
