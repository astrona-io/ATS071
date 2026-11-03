# Playground: Software Entities

This playground is a kind cluster with a small Starfleet estate. It does not run Backstage. It models the catalog backend: a pod named `catalog-tools` reads the descriptor files, checks them with the real `@backstage/catalog-model` library and prints one JSON report.

## What is in the box

- The namespace `catalog-source` holds the data. The ConfigMap `catalog-config` is the Backstage app configuration (key `app-config.yaml`). Each ConfigMap named `repo-<name>` is one descriptor repository, and each data key is a file.
- The repositories are `starfleet-org` (two Groups and one User), `bridge` (a System, a Component, an API and a Resource) and `scout` (a Component).
- The namespace `catalog-tools` holds the Deployment `catalog-tools`, which runs `node /opt/check/inspect.js`.

## The helper

Save this function in your shell. It sends every ConfigMap in `catalog-source` to the checker and filters the report with `jq`.

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

The useful parts of the report are `.entities`, `.errors`, `.unresolved`, `.conflicts` and `.summary`.

## Practice tasks

1. List the references of all ingested entities with `inspect_catalog -c '.summary.ingested'`.
2. Print the owner and the relations of `component:default/bridge`.
3. Find which entities consume `api:default/bridge-api`.
4. Change the owner of `scout` to a Group that does not exist and read `.unresolved`.
5. Remove the `kind` prefix from the `dependsOn` entry of `bridge` and read `.errors`.
6. Add a second descriptor file that declares `component:default/bridge` again and read `.conflicts`.
7. Add a Group with an owner field and a User with `memberOf` and read the relations the report derives.
8. Rename the System and find every entity that is now unresolved.
