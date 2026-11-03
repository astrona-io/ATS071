---
estimated_duration: 20m
---

# Lab: Automated Ingestion Capstone

Graded lab. **Status: UNTESTED.** It was built and checked statically only (`astrona validate`, `bash -n`, YAML parsing). Nobody has run it or its reference solution yet. The task is in `question.md`; the walkthrough is in `solution.md`.

The environment is a kind cluster. The descriptor files are ConfigMaps in `catalog-source`; a pod in `catalog-tools` runs `tools/inspect.js`, which checks them with the real `@backstage/catalog-model` library and models locations, rules, relations and providers. It does not run the Backstage application.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona submit --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona destroy ats-071-capstone-060
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-services-discovered.sh` | bridge, scout and shuttle are found by the provider and ingested |
| `validate-groups-ingested.sh` | The teams from the crew directory are ingested and every owner resolves |
| `validate-no-duplicate-claims.sh` | scout is claimed once, by the provider location |
| `validate-excluded-repos-not-discovered.sh` | vault, sandbox-test, deprecated-relay and hangar-legacy are not ingested |
| `validate-schedule-reasonable.sh` | The provider runs no more often than every 15 minutes and has a timeout |
| `validate-no-processing-errors.sh` | The report has no errors and the catalog has all six expected entities |
| `validate-provider-config-kept.sh` | The provider keeps its organization and branch filter and all eight repositories still exist |
