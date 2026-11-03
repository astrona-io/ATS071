# Automated Ingestion Playground

This playground is a clean environment for practising GitHub discovery. It does not run Backstage. It runs a model of the catalog backend: a pod that reads descriptor files and the catalog configuration, validates every entity with the real `@backstage/catalog-model` library, and applies the locations, rules and GitHub discovery providers in the way the catalog backend does. Nothing here is graded.

## What is in the box

A kind cluster with two namespaces.

- `catalog-source` holds eight ConfigMaps named `repo-<name>`. Each one stands for a repository in the GitHub organization `starfleet`. Each data key is a file in that repository.
- The annotations of a repository ConfigMap carry the facts that GitHub would report: `astrona.io/topics`, `astrona.io/visibility`, `astrona.io/default-branch` and `astrona.io/organization`.
- `catalog-source` also holds the ConfigMap `catalog-config` with the key `app-config.yaml`. It has the `catalog:` section of the Backstage configuration: `rules`, `locations` and `providers.github.starfleetServices`.
- `catalog-tools` holds the deployment `catalog-tools`, which runs `node /opt/check/inspect.js` and prints one JSON report.

The repositories are `starfleet-org` (the `org.yaml` file with the teams), `bridge` (internal), `scout` (public, with an extra file `legacy-info.yaml`), `shuttle` (public), `probe` (topic `experiment`), `vault` (private), `hangar-legacy` (default branch `master`) and `outpost-relay` (organization `outpost-labs`).

## Helper functions

Paste these into your terminal. The first prints the report and passes your arguments to `jq`. The next two save the catalog configuration to a local file and apply it again.

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
save_app_config() {
  kubectl -n catalog-source get configmap catalog-config -o jsonpath='{.data.app-config\.yaml}' > app-config.yaml
}
apply_app_config() {
  kubectl -n catalog-source create configmap catalog-config --from-file=app-config.yaml --dry-run=client -o yaml | kubectl apply -f -
}
```

Run `save_app_config`, edit `app-config.yaml`, then run `apply_app_config`. The report reads the new configuration at once.

## Report paths you will use

- `.config.providers.github` is the parsed provider configuration.
- `.locations[]` lists every location with `origin`, `target` and `status`. The origin of a discovered location is `provider:github:<id>`.
- `.summary.ingested` lists the entities that entered the catalog.
- `.errors[]`, `.conflicts[]` and `.unresolved[]` list what went wrong.

## Practice tasks

1. List the locations that the provider `starfleetServices` created: `inspect_catalog -c '[.locations[] | select(.origin | startswith("provider"))]'`. Name the repositories that are missing and find the filter that removed each one.
2. Print `.summary.ingested`. Explain why `component:default/probe` is not in the list.
3. Make `vault` visible to the provider with `kubectl -n catalog-source annotate configmap repo-vault astrona.io/visibility=internal --overwrite`. Check that `component:default/vault` appears. Then change the annotation back.
4. Add the topic `deprecated` to the `topic.exclude` list in `app-config.yaml`, annotate `repo-shuttle` with `astrona.io/topics=catalog,service,deprecated` and confirm that `shuttle` leaves the catalog.
5. Change `catalogPath` to `/legacy-info.yaml`. Find which repositories now give a `not-found` location, and what the errors list says about them.
6. Add a static location for `https://git.starfleet.example/scout/blob/main/legacy-info.yaml` under `catalog.locations`. Read `.conflicts` and find which location wins.
7. Set the schedule frequency to `{ hours: 1 }` and read `.config.providers.github.starfleetServices.schedule`. The model does not run a timer, so the report only shows the configuration. Explain what changes in a real backend.
8. Rename the provider id from `starfleetServices` to `fleetServices`. Check the `origin` of the locations and explain why a real backend treats this as a different provider.

Remember that this is a model. It never contacts GitHub, it does not use credentials and it ignores the schedule.
