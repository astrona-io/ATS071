# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab has not been run yet; the commands are checked statically only.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-010/module-01/labs/lab-01
```

`astrona submit` right after the start shows one passing check. `estate-kept` passes because nothing has changed yet. It is your guard.

## Step 1: Save the report helper and read the report

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

Print the errors and the unresolved relations:

```sh
inspect_catalog -c '{errors: .errors, unresolved: .unresolved}'
```

The report lists an error for `component:default/bridge` at the relations stage: the `dependsOn` reference `telemetry-db` has no kind. It also lists two unresolved relations: `api:default/bridge-api` is part of `system:default/navigaton`, and `component:default/scout` consumes `api:default/bridge-apis`. Neither target exists.

## Step 2: Fix the bridge repository

Save the descriptor file text of the `bridge` repository:

```sh
kubectl -n catalog-source get configmap repo-bridge -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
```

Open `catalog-info.yaml` and make three changes. In the Component `bridge`, set `owner` to `group:default/starfleet-ops` (the Group `bridge-crew` does not exist), and change the `dependsOn` entry to `resource:default/telemetry-db`. In the API `bridge-api`, change `system: navigaton` to `system: navigation`. Apply the file:

```sh
kubectl -n catalog-source create configmap repo-bridge --from-file=catalog-info.yaml --dry-run=client -o yaml | kubectl apply -f -
```

Print the report again:

```sh
inspect_catalog -c '{errors: .errors, unresolved: .unresolved}'
```

Only the `scout` relation remains. Submit:

```sh
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-010/module-01/labs/lab-01
```

`bridge-owner-exists`, `bridge-depends-on-database` and `api-belongs-to-system` now pass.

## Step 3: Fix the scout repository

```sh
kubectl -n catalog-source get configmap repo-scout -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
```

Change `consumesApis: [bridge-apis]` to `consumesApis: [bridge-api]` and apply it:

```sh
kubectl -n catalog-source create configmap repo-scout --from-file=catalog-info.yaml --dry-run=client -o yaml | kubectl apply -f -
```

Check that the report is clean:

```sh
inspect_catalog -c '.summary'
```

```sh
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-010/module-01/labs/lab-01
```

All six checks pass. If one still fails, read its hint and compare the relation targets in `inspect_catalog '.entities[] | {ref, relations}'` with the entity references that exist.
