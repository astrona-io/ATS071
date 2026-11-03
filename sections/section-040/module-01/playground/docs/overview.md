# Registered Locations Playground

This playground is a clean environment with no task and no grading. It is a kind cluster that holds a small Starfleet catalog setup, so you can practise the commands from the reading pages and break things on purpose.

It does not run Backstage. It is a model of the catalog backend. The descriptor files live in ConfigMaps, and a checker reads them and prints one JSON report. The checker validates every document with the real `@backstage/catalog-model` library. It models locations, `catalog.rules`, relations and conflicts. It does not model the database, the processing schedule, orphan handling or the registration API.

## What is in the box

The namespace `catalog-source` holds the "source": a ConfigMap named `repo-<name>` is one repository, and each key of its data is a file name. The ConfigMap `catalog-config` has the key `app-config.yaml`, the catalog section of the application configuration.

- `catalog-config`: four static locations in `catalog.locations`. The location for the file `org.yaml` has its own `rules` list that allows `Group` and `User`.
- `repo-starfleet-org`: the file `org.yaml` with two groups and one user.
- `repo-fleet-registry`: a `Location` entity in `catalog-info.yaml` that lists two relative targets, and the files `shuttle.yaml` and `cargo.yaml`.
- `repo-bridge`: the component `bridge`.
- `repo-legacy-probe`: the component `probe`, a retired service that is still registered.
- `repo-scout`: the component `scout`. It is not registered. Its ConfigMap has the annotation `astrona.io/default-branch: trunk`.

The namespace `catalog-tools` runs the pod `deploy/catalog-tools`, which holds the checker script.

A location target has the form `https://git.starfleet.example/<repo>/blob/<branch>/<file>`. It points at the ConfigMap `repo-<repo>` and the key `<file>`. The branch must equal the annotation `astrona.io/default-branch` of that ConfigMap, or `main` when the annotation is missing.

## The helper

Paste this function into your terminal. It sends all ConfigMaps of `catalog-source` to the checker and prints the report through `jq`:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

Useful report parts: `.locations[]` (every location the checker read, with `origin` and `status`), `.entities[]` (every document, with `ingested`), `.errors[]` (with the `stage`), `.conflicts[]` and `.summary.ingested`.

Start with these two commands:

```sh
inspect_catalog -c '.summary'
inspect_catalog -c '.locations[] | {target, origin, status}'
```

To change a descriptor, save the file text, edit it and apply it again:

```sh
kubectl -n catalog-source get configmap repo-bridge -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
kubectl -n catalog-source patch configmap repo-bridge --type merge -p "$(jq -n --rawfile text catalog-info.yaml '{data: {"catalog-info.yaml": $text}}')"
```

To change the catalog configuration, save the whole ConfigMap `catalog-config` to a file with `kubectl -n catalog-source get configmap catalog-config -o yaml > catalog-config.yaml`, edit the `app-config.yaml` text and run `kubectl apply -f catalog-config.yaml`. Remove the `resourceVersion`, `uid` and `creationTimestamp` lines first if `kubectl` complains.

## Practice tasks

1. List the locations with `.locations[]`. Find the entry whose `origin` is a URL and not `config`. Explain why the checker read `shuttle.yaml` without a line for it in `catalog.locations`.
2. Register `scout`. Add a location that points at its `catalog-info.yaml` with the branch `main`, and read the status. Then use the branch from the ConfigMap annotation and read the status again.
3. Remove the `rules` list from the `org.yaml` location. Read `.errors[]` and find the `rules` stage message for each group. Then add the rule back.
4. Change the second target of the `Location` entity to `./cargo.yml`. Read the status of that location and the error stage. Change it back.
5. Add `org.yaml` as a target of the `Location` entity and keep the static location for it too. Read `.locations[]`: the checker reads each URL once, so the file appears one time. Decide which registration should remain and why keeping both is not needed.
6. Remove the location of `legacy-probe` from `catalog-config`. Check that the component `probe` is gone from the report and that the ConfigMap `repo-legacy-probe` still exists.
7. Register the location of `legacy-probe` again and delete the ConfigMap `repo-legacy-probe`. Read the status and the stage of the error.
8. Add a second `Component` document named `bridge` to `shuttle.yaml`. Read `.conflicts[]` and see which location keeps the entity.

When you finish, destroy the playground with `astrona destroy ats-071-playground-040-01`.
