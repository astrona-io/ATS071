# Ingestion Troubleshooting - Playground

- **Slug:** ats-071-playground-050-01
- **Type:** Astrona playground, a clean environment with no task and no grading
- **Status:** UNTESTED. Built from static checks only (`astrona validate`).

A catalog estate with a working baseline and one broken repository, for reading the inspector report. The descriptor files are ConfigMaps in `catalog-source`. A pod in `catalog-tools` runs `tools/inspect.js`, which checks them with the real `@backstage/catalog-model` library and models locations, rules, relations and providers. The Backstage application itself is not run.

## Run it

```sh
astrona run -c .
astrona destroy ats-071-playground-050-01
```

`astrona destroy` takes the environment name, not the config path.
