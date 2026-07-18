# Marketing validation scripts

Run the repository gate from the project root:

```bash
npm run marketing:validate
```

`validate-marketing-data.mjs` is dependency-free so the audit gate does not depend on a data
framework or a network install. It validates:

- exact CSV headers, required fields, primitive types, enums, primary keys, and foreign keys;
- JSON and JSONL syntax plus registered experiment, report, and structured-prompt schemas;
- one validated metadata sidecar per dated report, including the report hash and a real analysis
  commit;
- experiment arm weights, entity references, metric references, and causal-claim discipline;
- prompt-block SHA-256 values against the exact fenced Veo text registered in `prompts.csv`;
- media/creative requirements that become stricter by asset kind and lifecycle state;
- creative input timeline/source ranges and same-layer overlap;
- publication audience residence, UTM, destination, and platform-object readiness;
- experiment plan/index immutability, pre-registration commit, arm, publication, and state lineage;
- ingestion file-to-Drive ID and performance-folder lineage;
- launch-pack campaign, audience, concept, prompt, metric, proof-shot, and edit-recipe lineage;
- real app proof appearing by second three in every launch edit recipe;
- current local checksums and byte counts for documents copied to Google Drive;
- aggregate-only privacy rules that reject user/install/session IDs and direct personal data;
- Git isolation for video, audio, editor-project, archive, and other large binary formats.

A pass proves structural consistency, not source truth, policy eligibility, statistical power, or
causality. Those require the review and decision gates documented under `marketing/operations/`.
Drive snapshot drift is reported separately from structural failures because it requires updating
the Drive copy and its registry checksum together, not weakening the data contract.

## Render the corrected `dia001` Veo + Swift proof cut

The active `dia001` renderer is a deterministic FFmpeg edit. It uses the approved Veo source,
retains its original audio, and cuts to App Store compositions made from real Swift screenshots.
The QR payload is completely covered by an editorial privacy mask. No browser recording is used.

```sh
marketing/scripts/render-dia001-veo-swift-proof.sh
```

Output:

```text
marketing/media/launch-001/prototypes/dia001/
  med_20260718_dia001v3__cmp_20260716_launch__veo-swift-proof-cut__sita-sharma.mp4
```

The export is exactly 192 frames: 1080×1920, 24 fps, 8 seconds, H.264/AAC. The first 55 frames
and frames 144–160 come from the Veo source. The remaining frames use the real Swift screenshot
compositions. `Sita Sharma` is the primary synthetic identity from `demoSeed-v1`.

The previous Playwright product-motion renderer is retained only as lineage for the rejected
`med_20260718_dia001dr` draft. Do not use it for new review exports. Final publication still
requires the continuous raw capture actions listed in `app-capture-shot-list.md`.
