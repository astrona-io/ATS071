---
estimated_duration: 20m
---

# Lab: Fix Lifecycle And Ownership

Graded lab. **Status: UNTESTED.** It was built and checked statically only (`astrona validate`, `bash -n`, YAML parsing). Nobody has run it or its reference solution yet. The task is in `question.md`; the walkthrough is in `solution.md`.

The environment is a kind cluster. The descriptor files are ConfigMaps in `catalog-source`; a pod in `catalog-tools` runs `tools/inspect.js`, which checks them with the real `@backstage/catalog-model` library. It does not run the Backstage application.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona submit --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona destroy ats-071-lab-010-02
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-shuttle-ingested.sh` | The shuttle Component is ingested with the lifecycle production |
| `validate-probe-deprecated.sh` | The probe Component is marked deprecated |
| `validate-cargo-owner-resolves.sh` | The cargo-hauler owner is a Group that exists |
| `validate-estate-intact.sh` | Nothing was deleted and the correct entries were kept (guard) |
