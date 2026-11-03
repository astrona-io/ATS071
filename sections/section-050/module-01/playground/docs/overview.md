# Ingestion Troubleshooting Playground

This playground is a clean environment with no task and no grading. It lets you read the evidence that catalog ingestion leaves behind and break the estate on purpose to see where each kind of error appears.

It does not run Backstage. The environment is a kind cluster with two namespaces. The namespace `catalog-source` holds the descriptor files as ConfigMaps. The namespace `catalog-tools` runs a pod that checks them with the real `@backstage/catalog-model` library and models the work of the catalog backend: reading locations, entity validation, `catalog.rules`, relations and identity conflicts. It is a model of the catalog backend, not the backend itself.

## What is in the box

- The ConfigMap `catalog-config` has the key `app-config.yaml`. It holds the `catalog:` section of a Backstage configuration: `rules` and four static `locations`.
- Each ConfigMap named `repo-<name>` is one descriptor repository. Each data key is a file. The location URL `https://git.starfleet.example/<name>/blob/main/<file>` points at the key `<file>` of the ConfigMap `repo-<name>`.
- `repo-starfleet-org` declares the groups `starfleet-ops` and `scout-team`.
- `repo-bridge` declares the Component `bridge` and the Resource `telemetry-db`.
- `repo-scout` declares the Component `scout`.
- `repo-probe` declares the Component `probe`. It has a fault.

## The helper function

Paste this function into your terminal. It sends all ConfigMaps to the inspector pod and passes your arguments to `jq`:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

The report has these parts:

- `.locations[]` has one item per location that was read, with `target`, `origin` and `status` (`ok`, `not-found` or `unsupported-target`).
- `.entities[]` has one item per document, with `kind`, `valid`, `errors`, `allowed`, `relations` and `ingested`.
- `.errors[]` has one item per error, with the `stage` (`fetch`, `parse`, `policy`, `kind`, `rules` or `relations`), the `location` and the `message`.
- `.conflicts[]` lists references that two locations declare.
- `.unresolved[]` lists relations whose target is not ingested.
- `.summary` has the list of ingested references and the number of errors.

## How to change a descriptor

Save the text of a file from a ConfigMap, edit it and write it back. The `create ... --dry-run=client -o yaml | kubectl apply -f -` form replaces the key you give and keeps the other keys of the ConfigMap:

```sh
kubectl -n catalog-source get configmap repo-probe -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
kubectl -n catalog-source create configmap repo-probe --from-file=catalog-info.yaml --dry-run=client -o yaml | kubectl apply -f -
```

Edit `catalog-info.yaml` between the two commands. To change `catalog-config`, save the full ConfigMap as a YAML file, edit it and run `kubectl apply -f` on the file.

## Practice tasks

1. Print `.summary`. Which entities are ingested, and how many errors does the report hold?
2. Print `.errors[]`. Name the stage, the location and the message of the error. Then print the `probe` item of `.entities[]` and compare its `valid` and `ingested` fields.
3. Repair the `probe` descriptor so that it is ingested. The error message names the missing property.
4. Change the location of `scout` in `catalog-config` from `blob/main/` to `blob/master/`. Print `.locations[]` and `.errors[]`. Which stage reports the error, and is the `scout` item still in `.entities[]`? Undo the change.
5. Add a colon followed by a space inside the unquoted `description` of `scout`, for example `Public site: for everyone`. Find the parse error and its line and column. Quote the value to repair it.
6. Remove `Resource` from `catalog.rules`. Which stage reports the error, which entity is not ingested, and what appears in `.unresolved[]`? Restore the rule.
7. Add a second Component named `bridge` to the `scout` file. Print `.conflicts[]`. Does the report add an item to `.errors[]` for the losing document? Remove the duplicate.
8. Delete the ConfigMap `repo-bridge` with `kubectl -n catalog-source delete configmap repo-bridge`. Compare `.locations[]`, `.errors[]` and `.unresolved[]`. Restore it with `kubectl apply -f` on a saved copy of its YAML.

The environment is untested until a maintainer has run it. Use `astrona destroy ats-071-playground-050-01` when you are done.
