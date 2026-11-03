---
estimated_duration: 20m
---

# Lab: Find And Fix Five Ingestion Faults

Graded lab. **Status: UNTESTED.** It was built and checked statically only (`astrona validate`, `bash -n`, YAML parsing). Nobody has run it or its reference solution yet. The task is in `question.md`; the walkthrough is in `solution.md`.

The environment is a kind cluster. The descriptor files are ConfigMaps in `catalog-source`; a pod in `catalog-tools` runs `tools/inspect.js`, which checks them with the real `@backstage/catalog-model` library and models locations, rules, relations and providers. It does not run the Backstage application.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona submit --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona destroy ats-071-lab-050-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-scout-fetched.sh` | The scout descriptor is fetched and ingested |
| `validate-drifter-parsed.sh` | The drifter descriptor parses and is ingested |
| `validate-probe-valid.sh` | The probe descriptor passes entity validation and is ingested |
| `validate-bridge-dependency-resolves.sh` | The telemetry-db Resource is ingested and the bridge dependency resolves |
| `validate-shuttle-no-conflict.sh` | No entity reference has two locations, the shuttle is ingested and bridge stays with its own repository |
| `validate-nothing-deleted.sh` | All repositories and the organization entities are still in place (passes at the start) |
