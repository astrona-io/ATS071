---
estimated_duration: 20m
---

# Lab: Fix Invalid Catalog Descriptors

Graded lab. **Status: UNTESTED.** It was built and checked statically only (`astrona validate`, `bash -n`, YAML parsing). Nobody has run it or its reference solution yet. The task is in `question.md`; the walkthrough is in `solution.md`.

The environment is a kind cluster. The descriptor files are ConfigMaps in `catalog-source`; a pod in `catalog-tools` runs `tools/inspect.js`, which checks them with the real `@backstage/catalog-model` library and models locations, rules, relations and providers. It does not run the Backstage application.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona submit --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona destroy ats-071-lab-020-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-org-groups-valid.sh` | The group starfleet-ops is accepted and its members resolve |
| `validate-telemetry-accepted.sh` | The telemetry Component is accepted as probe-telemetry |
| `validate-relay-has-lifecycle.sh` | The relay Component is accepted with lifecycle production |
| `validate-cargo-entities-accepted.sh` | The cargo Component and the cargo-api API are accepted and the API reference resolves |
| `validate-scanner-parses.sh` | The scanner file parses and the Component is accepted |
| `validate-catalog-intact.sh` | No repository or location was removed and the rules were not changed |
