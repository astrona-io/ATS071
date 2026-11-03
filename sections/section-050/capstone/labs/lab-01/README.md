---
estimated_duration: 20m
---

# Lab: Repair A Broken Catalog Estate

Graded lab. **Status: UNTESTED.** It was built and checked statically only (`astrona validate`, `bash -n`, YAML parsing). Nobody has run it or its reference solution yet. The task is in `question.md`; the walkthrough is in `solution.md`.

The environment is a kind cluster. The descriptor files are ConfigMaps in `catalog-source`; a pod in `catalog-tools` runs `tools/inspect.js`, which checks them with the real `@backstage/catalog-model` library and models locations, rules, relations and providers. It does not run the Backstage application.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona submit --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona destroy ats-071-capstone-050
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-org-kinds-allowed.sh` | The group outpost-ops is allowed by the catalog rules and ingested |
| `validate-drifters-group-valid.sh` | The drifters group passes the Group schema |
| `validate-users-location-reachable.sh` | The relative Location target resolves and kira is ingested |
| `validate-sensor-registered.sh` | The sensor location is read with a supported location type |
| `validate-beacon-dependency-resolves.sh` | The dependsOn reference is complete and resolves |
| `validate-relay-valid.sh` | The relay descriptor passes entity validation |
| `validate-api-single-owner.sh` | No reference has two locations and relay has an API of its own |
| `validate-nothing-deleted.sh` | Repositories, rules and existing entities are still in place (passes at the start) |
