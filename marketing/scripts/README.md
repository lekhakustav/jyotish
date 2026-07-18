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

## Render the `dia001` product-motion prototype

The `dia001` renderer records a reusable Swift-faithful HTML motion source and combines it with
the approved Veo family scene. It exports one compact review MP4 into the ignored media
workspace and uses only the synthetic identity `Sita Sharma`.

```sh
node marketing/scripts/render-dia001-product-motion.mjs
```

Output:

```text
marketing/media/launch-001/prototypes/dia001/
  med_20260718_dia001dr__cmp_20260716_launch__product-motion-draft__sita-sharma.mp4
```

The product visualization masks the QR-like visual and contains no real birth data. It remains
a review draft until it passes the launch preflight checklist.
