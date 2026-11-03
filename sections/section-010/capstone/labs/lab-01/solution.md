# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab has not been run yet; the commands are checked statically only.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-010/capstone/labs/lab-01
```

`astrona submit` right after the start shows one passing check. `owners-kept` passes because nothing has changed yet. It is your guard.

## Step 1: Save the helper and read the estate

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

```sh
inspect_catalog -c '{ingested: .summary.ingested, unresolved: .unresolved}'
```

Four entities exist (two Components and two Groups). `berth-board` has an unresolved `consumesApi` relation to `api:default/gate-api`.

## Step 2: Add the System, Domain, API and Resource to the gate repository

Save the file text of the repository:

```sh
kubectl -n catalog-source get configmap repo-gate -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
```

Edit `catalog-info.yaml`. In the Component `gate`, add `system: shipyard`, `providesApis: [gate-api]` and `dependsOn: [resource:default/dock-db]` under `spec`. Then add four documents, each separated by a line that holds only `---`: a Domain `logistics` (spec `owner: yard-ops`), a System `shipyard` (spec `owner: yard-ops` and `domain: logistics`), an API `gate-api` (spec `type: openapi`, `lifecycle: production`, `owner: yard-ops`, `system: shipyard` and a `definition`) and a Resource `dock-db` (spec `type: database`, `owner: yard-ops`, `system: shipyard`). Apply the file:

```sh
kubectl -n catalog-source create configmap repo-gate --from-file=catalog-info.yaml --dry-run=client -o yaml | kubectl apply -f -
```

```sh
inspect_catalog -c '{errors: .errors, unresolved: .unresolved}'
```

An error here points at the document that the real catalog model rejected. A common cause is a missing required field such as `definition` on the API or `domain` spelled wrongly. Submit:

```sh
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-010/capstone/labs/lab-01
```

Checks `system-in-domain`, `api-provided-by-gate` and `gate-database` now pass.

## Step 3: Put berth-board in the System

```sh
kubectl -n catalog-source get configmap repo-berth -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
```

Add `system: shipyard` under `spec` and apply it:

```sh
kubectl -n catalog-source create configmap repo-berth --from-file=catalog-info.yaml --dry-run=client -o yaml | kubectl apply -f -
```

```sh
inspect_catalog -c '.summary'
```

```sh
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-010/capstone/labs/lab-01
```

All seven checks pass. If one fails, print `inspect_catalog '.entities[] | {ref, ingested, relations}'` and compare each relation target with an entity reference that the report lists.
