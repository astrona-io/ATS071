---
estimated_duration: 20m
---

# Lab: Register An Estate

Graded lab. **Status: UNTESTED.** It was built and checked statically only (`astrona validate`, `bash -n`, YAML parsing). Nobody has run it or its reference solution yet. The task is in `question.md`; the walkthrough is in `solution.md`.

The environment is a kind cluster. The descriptor files are ConfigMaps in `catalog-source`; a pod in `catalog-tools` runs `tools/inspect.js`, which checks them with the real `@backstage/catalog-model` library and models locations, rules, relations and providers. It does not run the Backstage application.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona submit --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona destroy ats-071-capstone-040
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-registry-registered.sh` | The root Location of the registry repository is registered and read |
| `validate-groups-ingested.sh` | The groups and the user from the teams file are ingested |
| `validate-components-allowed.sh` | The components of the services file are ingested and Component is still allowed |
| `validate-sensors-fetched.sh` | The sensor-array Component is ingested from its absolute target |
| `validate-no-conflicts.sh` | No entity is claimed by two locations |
| `validate-relay-from-outpost.sh` | outpost-relay is ingested from the outpost repository |
| `validate-old-sensors-retired.sh` | old-sensors is gone and the rest of the services file remains |
| `validate-estate-intact.sh` | Every repository still exists, the outpost location is kept and no relation is unresolved |
