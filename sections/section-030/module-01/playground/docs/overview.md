# Catalog Annotations Playground

This playground is a kind cluster that holds Starfleet descriptor files and a small checker. It does not run Backstage. Each descriptor repository is a ConfigMap named `repo-<name>` in the namespace `catalog-source`, and each key in the ConfigMap is a file name. The ConfigMap `catalog-config` holds the `catalog` section of an app-config file. A pod in the namespace `catalog-tools` runs a script that checks every descriptor with the `@backstage/catalog-model` library, the library the real catalog backend uses, and models locations, rules and relations. It is a model of the catalog backend, not the Backstage backend.

## What is in the box

- `repo-starfleet-org`: the Groups `starfleet-ops` and `scout-team`.
- `repo-bridge`: the Component `bridge` with six annotations: `backstage.io/techdocs-ref`, `backstage.io/source-location`, `github.com/project-slug`, `backstage.io/kubernetes-id`, `backstage.io/kubernetes-label-selector` and `backstage.io/view-url`.
- `repo-scout`: the Component `scout`. Its `github.com/project-slug` and `backstage.io/kubernetes-id` annotations hold values copied from `bridge`.
- `repo-shuttle`: the Component `shuttle`, with no annotations.
- `catalog-config`: the four static locations that load these files.

## The helper

Paste this function into your terminal. It sends all ConfigMaps in `catalog-source` to the checker and filters the JSON report with `jq`:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

Useful filters: `.entities[] | {ref, annotations: .metadata.annotations}` shows annotations, `.errors[]` shows failures and `.summary` shows what was ingested. The checker adds `backstage.io/managed-by-location` to every entity, as the catalog backend does.

To change a descriptor, save the file text, edit it, and apply the ConfigMap again:

```sh
kubectl -n catalog-source get configmap repo-scout -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
kubectl -n catalog-source create configmap repo-scout --from-file=catalog-info.yaml --dry-run=client -o yaml | kubectl apply -f -
```

## Practice tasks

1. The `drifter` team asks where `scout` documentation lives. Add `backstage.io/techdocs-ref: dir:.` to `scout` and print its annotations.
2. Correct the project slug and the Kubernetes id of `scout` so that they name `scout`.
3. Move a value on purpose: put `backstage.io/techdocs-ref: dir:.` under `labels` in `bridge`. Read the error, then move it back.
4. Write an annotation value without quotes, such as `example.com/pager-enabled: true`, on `shuttle`. Read the error and fix it with quotes.
5. Write an annotation key that contains a space on `shuttle`. Read the error.
6. Compare the `backstage.io/managed-by-location` value of each entity with the location in `catalog-config`.
7. Add `backstage.io/edit-url` to `bridge` and print it.
8. Remove `spec.lifecycle` from `shuttle` and put it in an annotation. Read the kind error, and restore it.
