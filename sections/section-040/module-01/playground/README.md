# Registered Locations - Playground

- **Slug:** ats-071-playground-040-01
- **Type:** Astrona playground, a clean environment with no task and no grading
- **Status:** UNTESTED. Built from static checks only (`astrona validate`).

Static locations, a Location entity, per-location rules and a retired repository in ConfigMaps, with a checker that uses @backstage/catalog-model. The descriptor files are ConfigMaps in `catalog-source`. A pod in `catalog-tools` runs `tools/inspect.js`, which checks them with the real `@backstage/catalog-model` library and models locations, rules, relations and providers. The Backstage application itself is not run.

## Run it

```sh
astrona run -c .
astrona destroy ats-071-playground-040-01
```

`astrona destroy` takes the environment name, not the config path.
