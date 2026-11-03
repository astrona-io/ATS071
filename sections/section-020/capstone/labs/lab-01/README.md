---
estimated_duration: 20m
---

# Lab: Descriptors, Rules And Locations Capstone

Graded lab. **Status: UNTESTED.** It was built and checked statically only (`astrona validate`, `bash -n`, YAML parsing). Nobody has run it or its reference solution yet. The task is in `question.md`; the walkthrough is in `solution.md`.

The environment is a kind cluster. The descriptor files are ConfigMaps in `catalog-source`; a pod in `catalog-tools` runs `tools/inspect.js`, which checks them with the real `@backstage/catalog-model` library and models locations, rules, relations and providers. It does not run the Backstage application.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona submit --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona destroy ats-071-capstone-020
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-rules-allow-system-and-location.sh` | System and Location entities are allowed and accepted |
| `validate-org-accepted-from-org-file.sh` | The groups and the user of the organization file are accepted |
| `validate-rogue-group-stays-blocked.sh` | A Group declared in the harbor repository is still not accepted |
| `validate-harbor-relations-resolve.sh` | harbor-control is accepted and its owner and system resolve |
| `validate-dock-location-registered.sh` | The dock repository is a configured location that can be read |
| `validate-dock-entities-valid.sh` | dock-gate and dock-api are accepted and the API reference resolves |
| `validate-ops-services-read.sh` | The service file listed by the ops Location is read and ops-gateway is accepted |
| `validate-catalog-intact.sh` | No repository was removed and the Component and API kinds are still allowed |
