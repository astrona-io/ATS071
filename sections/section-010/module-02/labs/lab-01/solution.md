# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab has not been run yet; the commands are checked statically only.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-010/module-02/labs/lab-01
```

`astrona submit` right after the start shows one passing check. `estate-intact` passes because nothing has changed yet. It is your guard.

## Step 1: Read the report

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
inspect_catalog -c '{errors: .errors, unresolved: .unresolved}'
```

The report lists an error for `shuttle` at the stage `kind`: the property `lifecycle` is missing. It also lists an unresolved `ownedBy` relation: `cargo-hauler` names the Group `fleet-crew`, which no file declares. The lifecycle `retired` of `probe` is valid text, so the report has no error for it.

## Step 2: Fix shuttle

```sh
kubectl -n catalog-source get configmap repo-shuttle -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
```

Add `lifecycle: production` under `type: service` in the `spec`. Apply the file:

```sh
kubectl -n catalog-source create configmap repo-shuttle --from-file=catalog-info.yaml --dry-run=client -o yaml | kubectl apply -f -
```

## Step 3: Mark probe as deprecated

```sh
kubectl -n catalog-source get configmap repo-probe -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
```

Change `lifecycle: retired` to `lifecycle: deprecated` and apply the file:

```sh
kubectl -n catalog-source create configmap repo-probe --from-file=catalog-info.yaml --dry-run=client -o yaml | kubectl apply -f -
```

## Step 4: Fix the owner of cargo-hauler

```sh
kubectl -n catalog-source get configmap repo-cargo-hauler -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
```

Change `owner: fleet-crew` to `owner: starfleet-ops` and apply the file:

```sh
kubectl -n catalog-source create configmap repo-cargo-hauler --from-file=catalog-info.yaml --dry-run=client -o yaml | kubectl apply -f -
inspect_catalog -c '{errors: .errors, unresolved: .unresolved}'
```

Both lists are empty. Submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-010/module-02/labs/lab-01
```

All checks pass. Destroy the lab with `astrona destroy ats-071-lab-010-02`.
