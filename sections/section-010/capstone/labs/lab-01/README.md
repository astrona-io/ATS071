---
estimated_duration: 20m
---

# Lab: Model The Shipyard Estate

Graded lab. **Status: UNTESTED.** It was built and checked statically only (`astrona validate`, `bash -n`, YAML parsing). Nobody has run it or its reference solution yet. The task is in `question.md`; the walkthrough is in `solution.md`.

The environment is a kind cluster. The descriptor files are ConfigMaps in `catalog-source`; a pod in `catalog-tools` runs `tools/inspect.js`, which checks them with the real `@backstage/catalog-model` library and models locations, rules, relations and providers. It does not run the Backstage application.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona submit --git ssh://git@github.com/astrona-io/ATS071.git -c <path-to-this-lab>
astrona destroy ats-071-capstone-010
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-system-in-domain.sh` | The System shipyard exists, is owned by yard-ops and is part of the Domain logistics |
| `validate-api-provided-by-gate.sh` | The API gate-api exists in the System shipyard and the gate Component provides it |
| `validate-gate-database.sh` | The Resource dock-db exists in shipyard and the gate Component depends on it |
| `validate-components-in-system.sh` | The Components gate and berth-board are both part of the System shipyard |
| `validate-berth-board-consumes-api.sh` | The berth-board Component consumes gate-api and the relation resolves |
| `validate-clean-report.sh` | The catalog has no processing errors and no unresolved relations |
| `validate-owners-kept.sh` | The three repositories, both teams and the owner of berth-board are unchanged |
