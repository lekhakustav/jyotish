# Google Drive media workspace

**Verified:** 2026-07-16  
**Connected account:** `admin@sodhera.com` (Sodhera Admin)  
**Root:** [Jyotish Baje Marketing](https://drive.google.com/drive/folders/1aKPYc8aF5qJYTSLD7dAW-EgRLrgSum21)  
**Root folder ID:** `1aKPYc8aF5qJYTSLD7dAW-EgRLrgSum21`

The root and its first-level children were created and read back through Google Drive. Access
visibility was not changed during setup. Add named collaborators deliberately; do not make the
folder public merely for convenience.

## Folder contract

```text
Jyotish Baje Marketing/
  00_START_HERE/            Drive-readable operating documents
  01_INBOX/                 temporary, unclassified uploads
  02_SOURCE_ASSETS/
    app-captures/           sanitized product recordings
    brand-assets/           approved logos and brand exports
    stock-and-b-roll/       licensed third-party media
    music-and-sfx/          licensed audio
    references/             visual references, never assumed licensed for reuse
  03_AI_GENERATIONS/
    veo-scenes/             untouched original generated videos
    ai-voice/               generated voice masters
    images-and-graphics/    generated supporting visuals
  04_EDIT_PROJECTS/         editor project folders and linked source bundles
  05_EXPORTS/
    drafts/                 work in progress
    review/                 review candidates
    final-masters/          approved platform-neutral masters
  06_PUBLISHED/
    instagram/              exact uploaded Instagram files
    tiktok/                 exact uploaded TikTok files
  07_PERFORMANCE_EXPORTS/
    instagram/              raw aggregate platform exports
    tiktok/                 raw aggregate platform exports
    app-store-and-play/     aggregate store analytics exports
  99_ARCHIVE/               superseded folders retained for provenance
```

All verified folder IDs live in `marketing/registry/drive-folders.csv`.

## Media ingestion

1. Generate a stable `media_id` before upload.
2. Use a filename beginning with that ID.
3. Upload to the narrowest canonical folder, not `01_INBOX` when classification is known.
4. Download/read the uploaded file metadata and record the Drive file ID and URL.
5. Compute SHA-256 from the original local bytes and record byte size, duration, dimensions,
   codec, rights basis, prompt ID, and app Git SHA where applicable.
6. Move the local working copy under ignored `marketing/media/` or remove it only after the
   Drive copy and checksum are verified.

## Versioning

Never silently overwrite a master. A changed image, crop, voice, timing, caption burn-in, or
export creates a new `media_id`. `parent_media_id` links derivations. Drive paths are for humans;
the immutable identity is `media_id + drive_file_id + sha256`.

## Sharing

Share the root with named collaborators as `viewer` or `commenter` by default and grant
`editor` only to people producing assets. Confirm ownership before changing permissions.
Public-link sharing requires an explicit business decision because birth-profile screenshots,
licensed stock, platform exports, and unpublished campaign work may be sensitive.
