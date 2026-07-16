# Experiment records

Create one directory per experiment:

```text
experiments/<experiment_id>/
  plan.json
  amendments.jsonl
  analysis.md
  decision.md
```

Copy the corresponding files from `marketing/templates/`. Replace every placeholder, register
the experiment in `registry/experiments.csv`, and commit the plan before launch. Add the
pre-registration commit SHA to the index in a follow-up commit; Git itself is the immutable proof
of what was known before results.

Plan changes are append-only records in `amendments.jsonl`. Do not revise the hypothesis, primary
metric, exclusions, or stopping rule after viewing outcomes without recording the change as a
post hoc amendment.

`platform_split_test` and another genuinely randomized design may support causal language when
assignment and implementation are verified. `organic_observational`, `matched_observational`, and
ordinary optimized platform delivery remain observational.

Run `npm run marketing:validate` before launch and again before committing analysis or a decision.
