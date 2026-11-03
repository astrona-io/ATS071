---
estimated_duration: 20m
---

# Lab: Fix GitHub Discovery Filters

Graded lab. **Status: UNTESTED.** It was built and checked statically only (`astrona validate`, `bash -n`, YAML parsing). Nobody has run it or its reference solution yet. The task is in `question.md`; the walkthrough is in `solution.md`.

The environment is a kind cluster. The descriptor files are ConfigMaps in `catalog-source`; a pod in `catalog-tools` runs `tools/inspect.js`, which checks them with the real `@backstage/catalog-model` library and models locations, rules, relations and providers. It does not run the Backstage application.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona submit --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona destroy ats-071-lab-060-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-provider-locations-resolve.sh` | The provider produces at least three locations and every one of them is found |
| `validate-public-services-ingested.sh` | The public repositories scout and shuttle are ingested through the provider |
| `validate-experiment-excluded.sh` | The experimental probe repository is not ingested while other services are |
| `validate-private-repo-not-discovered.sh` | The internal bridge is discovered and the private vault is not |
| `validate-schedule-reasonable.sh` | The provider runs no more often than every 10 minutes and has a timeout |
| `validate-scope-not-widened.sh` | The provider keeps its organization and branch scope and the descriptor repositories still exist |
