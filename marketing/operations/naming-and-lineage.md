# Naming and lineage

## Stable IDs

Use `<prefix>_<YYYYMMDD>_<six-lowercase-alphanumeric>`:

| Entity | Prefix | Example |
| --- | --- | --- |
| Campaign | `cmp` | `cmp_20260716_launch01` |
| Audience | `aud` | `aud_20260716_np4054` |
| Concept | `cpt` | `cpt_20260716_family` |
| Prompt | `prm` | `prm_20260716_a1b2c3` |
| Media | `med` | `med_20260716_d4e5f6` |
| Creative | `crv` | `crv_20260716_g7h8j9` |
| Publication | `pub` | `pub_20260716_k1m2n3` |
| Experiment | `exp` | `exp_20260716_p4q5r6` |
| Arm | `arm` | `arm_20260716_s7t8v9` |
| Ingestion | `ing` | `ing_20260716_w1x2y3` |

IDs are permanent. Never recycle an ID, even when an entity is abandoned.

## Lineage

```text
campaign_id
  -> audience_id + concept_id
  -> prompt_id
  -> media_id(s)
  -> creative_id
  -> publication_id
  -> platform observation rows
  -> acquisition cohort snapshot
  -> experiment_id / arm_id
  -> decision
```

Every join uses an ID. Titles and filenames are display labels only.

## Filenames

Use lowercase ASCII, hyphens, and a leading stable ID:

```text
med_20260716_d4e5f6-family-table-veo-v01.mp4
med_20260716_h7j8k9-kundali-proof-ios-en-v01.mov
crv_20260716_g7h8j9-family-table-ne-v01-master.mp4
```

Never use `final`, `final-final`, dates without IDs, or a person's name. Version numbers describe
file iterations; a material treatment change still receives a new entity ID.

## Creative mutation rule

A change to hook, speaker, voice, language, crop, duration, first-frame text, app proof, CTA,
music, or caption timing creates a new `creative_id` and records `supersedes_creative_id`.
Encoding-only delivery exports may remain children of the same creative through distinct
`media_id` rows.
