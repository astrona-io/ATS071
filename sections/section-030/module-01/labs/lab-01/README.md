---
estimated_duration: 20m
---

# Lab: Fix Catalog Annotations

Graded lab. **Status: UNTESTED.** It was built and checked statically only (`astrona validate`, `bash -n`, YAML parsing). Nobody has run it or its reference solution yet. The task is in `question.md`; the walkthrough is in `solution.md`.

The environment is a kind cluster. The descriptor files are ConfigMaps in `catalog-source`; a pod in `catalog-tools` runs `tools/inspect.js`, which checks them with the real `@backstage/catalog-model` library and models locations, rules, relations and providers. It does not run the Backstage application.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona submit --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona destroy ats-071-lab-030-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-bridge-techdocs.sh` | The bridge Component carries techdocs-ref as an annotation |
| `validate-scout-project-slug.sh` | The scout Component points at its own GitHub repository |
| `validate-scout-kubernetes.sh` | The scout Component maps to its own Kubernetes workloads |
| `validate-shuttle-valid-annotations.sh` | The shuttle Component is ingested and keeps its pager annotation as a string |
| `validate-shuttle-no-secret.sh` | No annotation on the shuttle Component holds a token |
| `validate-estate-intact.sh` | Nothing was deleted and the correct annotations were kept (guard) |
