# Marketing validation scripts

Run the repository gate from the project root:

```bash
npm run marketing:validate
```

`validate-marketing-data.mjs` is dependency-free so the audit gate does not depend on a data
framework or a network install. It validates:

- exact CSV headers, required fields, primitive types, enums, primary keys, and foreign keys;
- JSON and JSONL syntax plus registered experiment, report, and structured-prompt schemas;
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
