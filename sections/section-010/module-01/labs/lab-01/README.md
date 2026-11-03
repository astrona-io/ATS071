---
estimated_duration: 20m
---

# Lab: Fix Ownership And Relations

Graded lab. **Status: UNTESTED.** It was built and checked statically only (`astrona validate`, `bash -n`, YAML parsing). Nobody has run it or its reference solution yet. The task is in `question.md`; the walkthrough is in `solution.md`.

The environment is a kind cluster. The descriptor files are ConfigMaps in `catalog-source`; a pod in `catalog-tools` runs `tools/inspect.js`, which checks them with the real `@backstage/catalog-model` library and models locations, rules, relations and providers. It does not run the Backstage application.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona submit --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona destroy ats-071-lab-010-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-bridge-owner-exists.sh` | The bridge Component is ingested and owned by the Group starfleet-ops |
| `validate-bridge-depends-on-database.sh` | The bridge Component depends on the resource telemetry-db and the relation resolves |
| `validate-api-belongs-to-system.sh` | The bridge-api API is part of the System navigation |
| `validate-scout-consumes-bridge-api.sh` | The scout Component consumes the API bridge-api and the relation resolves |
| `validate-no-errors-no-unresolved.sh` | The catalog has no processing errors and no unresolved relations |
| `validate-estate-kept.sh` | Nothing was deleted, the three repositories and the owners are still in place |
