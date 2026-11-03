---
estimated_duration: 20m
---

# Lab: Fix Registered Locations

Graded lab. **Status: UNTESTED.** It was built and checked statically only (`astrona validate`, `bash -n`, YAML parsing). Nobody has run it or its reference solution yet. The task is in `question.md`; the walkthrough is in `solution.md`.

The environment is a kind cluster. The descriptor files are ConfigMaps in `catalog-source`; a pod in `catalog-tools` runs `tools/inspect.js`, which checks them with the real `@backstage/catalog-model` library and models locations, rules, relations and providers. It does not run the Backstage application.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona submit --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona destroy ats-071-lab-040-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-scout-ingested.sh` | The scout Component is registered and ingested |
| `validate-org-entities-ingested.sh` | The groups and the user of the organization file are ingested |
| `validate-global-rules-unchanged.sh` | The global catalog rules were not widened |
| `validate-fleet-components-ingested.sh` | Both fleet components are ingested through the Location entity |
| `validate-probe-retired.sh` | The probe is no longer registered and its repository still exists |
| `validate-no-fetch-errors.sh` | No location fails to fetch |
| `validate-bridge-untouched.sh` | The bridge Component is still ingested and no repository was deleted |
