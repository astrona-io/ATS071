---
estimated_duration: 20m
---

# Lab: Annotations Capstone

Graded lab. **Status: UNTESTED.** It was built and checked statically only (`astrona validate`, `bash -n`, YAML parsing). Nobody has run it or its reference solution yet. The task is in `question.md`; the walkthrough is in `solution.md`.

The environment is a kind cluster. The descriptor files are ConfigMaps in `catalog-source`; a pod in `catalog-tools` runs `tools/inspect.js`, which checks them with the real `@backstage/catalog-model` library and models locations, rules, relations and providers. It does not run the Backstage application.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona submit --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona destroy ats-071-capstone-030
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-probe-annotation-key.sh` | The probe Component is ingested and keeps its on-call link under a valid key |
| `validate-probe-no-secret.sh` | No annotation on the probe Component holds a password |
| `validate-bridge-slug-format.sh` | The bridge project slug uses the owner/repository format |
| `validate-scout-docs-and-source.sh` | The scout Component declares its TechDocs source and a source location |
| `validate-shuttle-own-identity.sh` | The shuttle Component carries its own identity annotations |
| `validate-shuttle-lifecycle-in-spec.sh` | The shuttle lifecycle is a spec field, not an annotation |
| `validate-estate-intact.sh` | Nothing was deleted and the correct annotations were kept (guard) |
