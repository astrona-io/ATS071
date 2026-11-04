# Describing And Finding Software - Playground

- **Slug:** ats-071-playground-010-02
- **Type:** Astrona playground, a clean environment with no task and no grading
- **Status:** UNTESTED. Built from static checks only (`astrona validate`).

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with a checker pod in `catalog-tools` and a Starfleet estate with several lifecycles, types and tags, stored as ConfigMaps in `catalog-source`. The checker validates the descriptors with `@backstage/catalog-model`. It models the catalog backend and does not run Backstage.

## Run it

```sh
astrona run -c .
astrona destroy ats-071-playground-010-02
```

`astrona destroy` takes the environment name, not the config path. The guide for learners is `docs/overview.md`.
