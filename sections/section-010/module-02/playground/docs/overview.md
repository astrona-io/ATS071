# Describing And Finding Software Playground

This playground is a clean environment with no task and no grading. It is a kind cluster that holds a small Starfleet catalog, so you can practise filtering the catalog and auditing its quality.

It does not run Backstage. The descriptor files are ConfigMaps in the namespace `catalog-source`, and a checker pod in `catalog-tools` reads them with the real `@backstage/catalog-model` library and prints one JSON report.

## What is in the box

- `repo-starfleet-org`: the groups `starfleet-ops` and `scout-team`, and the user `kira`.
- `repo-bridge`: the system `navigation`, the component `bridge` (type `service`, lifecycle `production`), the API `bridge-api` and the resource `telemetry-db`.
- `repo-scout`: the component `scout` (type `website`, lifecycle `experimental`).
- `repo-shuttle`: the component `shuttle` (type `service`, lifecycle `production`, tag `cargo`), which depends on `probe`.
- `repo-probe`: the component `probe` (type `service`, lifecycle `deprecated`, tag `legacy`).
- `catalog-config`: the locations of the five repositories.

## The helper

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

## Practice tasks

1. List every component with its type, lifecycle and owner.
2. List the entities that have the lifecycle `deprecated` and find which components depend on them.
3. List the entities that have no tags and the components that have no description.
4. Change the lifecycle of `scout` to `production`, apply the file and list the production components again.
5. Remove `lifecycle` from `shuttle` and read the error. Put it back.
6. Change the owner of `shuttle` to `fleet-crew` and read `.unresolved`. Put it back.

When you finish, destroy the playground with `astrona destroy ats-071-playground-010-02`.
