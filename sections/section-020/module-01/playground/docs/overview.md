# Playground: Descriptors, Policies And Rules

This playground is a kind cluster that holds a small catalog source. It does **not** run Backstage. The descriptor files are ConfigMaps in the namespace `catalog-source`, and a pod in the namespace `catalog-tools` reads them with the real `@backstage/catalog-model` library, the library the Backstage catalog backend uses to validate entities. Locations, `catalog.rules` and relations are a small model of the catalog backend, not the backend itself.

## What is in the box

Each repository is one ConfigMap named `repo-<name>`. Every data key of the ConfigMap is one file of that repository.

- `repo-starfleet-org`: the file `org.yaml` with two `Group` entities and one `User` entity.
- `repo-bridge`: the file `catalog-info.yaml` with a `System` and a `Component`, in one multi-document file.
- `repo-scout`: the file `catalog-info.yaml` with one valid `Component`.
- `repo-probe`: the file `catalog-info.yaml` with three `Component` documents. Two of them are invalid.
- `repo-shuttle`: a valid `Component` file that no location points at yet.

The ConfigMap `catalog-config` holds the key `app-config.yaml`. Its `catalog` section lists four static locations (the organization file, `bridge`, `scout` and `probe`). The organization location has its own rule that allows `Group` and `User`. The configuration sets no global `catalog.rules`, so the default rules apply.

## The helper function

Paste this once in your terminal. It sends every ConfigMap to the inspector pod and prints the JSON report through `jq`:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

Useful queries:

```sh
inspect_catalog -r '.summary.ingested[]'
inspect_catalog -c '.errors[]'
inspect_catalog -c '.entities[] | {declared, valid, allowed, ingested}'
inspect_catalog -c '.locations[] | {target, status}'
```

## How to change a descriptor

Save the file text of a repository on your machine, edit it, and apply it back. This example saves the `probe` file:

```sh
kubectl -n catalog-source get configmap repo-probe -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
```

After you edit `catalog-info.yaml`, update the ConfigMap. The command replaces the key `catalog-info.yaml` and leaves other keys of the ConfigMap alone:

```sh
kubectl -n catalog-source create configmap repo-probe --from-file=catalog-info.yaml --dry-run=client -o yaml | kubectl apply -f -
```

To change the catalog configuration, save the key `app-config.yaml` of `catalog-config` the same way, edit it, and apply it again with `--from-file=app-config.yaml`.

## Practice tasks

1. List the entities the catalog accepts and compare the list with the entities declared in the files.
2. Find the two errors in `repo-probe` and read the stage (`policy` or `kind`) of each one.
3. Fix the invalid `metadata.name` in the first `probe` document and check that the entity is accepted.
4. Add the missing required field to `probe-relay` and check the report again.
5. Add a `Location` target for the `shuttle` repository to `catalog-config` and check that `component:default/shuttle` is accepted.
6. Remove `Group` and `User` from the organization location rule and read the `rules` errors that appear. Then restore the rule.
7. Add a global `catalog.rules` list that allows only `Component` and `Location`, and see which entities disappear. Remove it again.

Nothing here is graded. Destroy the playground when you finish.
