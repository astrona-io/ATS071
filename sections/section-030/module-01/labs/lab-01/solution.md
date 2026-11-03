# Solution

Solve this lab on `terminal`. This lab has not been run yet; the commands are checked statically only. The guard check (`validate-estate-intact.sh`) already passes before you change anything. It fails only if you delete a repository ConfigMap or change an annotation that was correct.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-030/module-01/labs/lab-01
```

Paste the helper that runs the inspector. It sends the ConfigMaps to the `catalog-tools` pod and filters the report with `jq`. The pod models the catalog backend; it does not run Backstage:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

## Step 1: Read the errors

```sh
inspect_catalog -c '.errors[] | {location, stage, message}'
```

Two entities fail the policy stage. The message for `bridge` says that `labels.backstage.io/techdocs-ref` is not valid: label values must be short names, and `dir:.` is not one. The message for `shuttle` says that `example.com/pager-enabled` must be a string: the YAML value `true` without quotes is a boolean. `scout` has no error, because its values are valid strings, but they name the wrong objects. Check them:

```sh
inspect_catalog -c '.entities[] | select(.ref == "component:default/scout") | .metadata.annotations'
```

## Step 2: Move techdocs-ref on bridge

```sh
kubectl -n catalog-source get configmap repo-bridge -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
```

In the file, delete the `backstage.io/techdocs-ref: dir:.` line under `labels`. Add it under `annotations`, next to `github.com/project-slug`. Then apply the file and check the entity:

```sh
kubectl -n catalog-source create configmap repo-bridge --from-file=catalog-info.yaml --dry-run=client -o yaml | kubectl apply -f -
inspect_catalog -c '.entities[] | select(.ref == "component:default/bridge") | {ingested, annotations: .metadata.annotations}'
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-030/module-01/labs/lab-01
```

## Step 3: Correct the values on scout

`scout` copied its values from `bridge`. Save its file:

```sh
kubectl -n catalog-source get configmap repo-scout -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
```

Change the three values to `starfleet-org/scout`, `scout` and `app=scout`. Then apply the file and check:

```sh
kubectl -n catalog-source create configmap repo-scout --from-file=catalog-info.yaml --dry-run=client -o yaml | kubectl apply -f -
inspect_catalog -c '.entities[] | select(.ref == "component:default/scout") | .metadata.annotations'
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-030/module-01/labs/lab-01
```

## Step 4: Repair shuttle

```sh
kubectl -n catalog-source get configmap repo-shuttle -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
```

Put quotes around the pager value so it reads `example.com/pager-enabled: "true"`. Delete the `example.com/ci-token` line. A token in an annotation is visible to everyone who can read the catalog; the right fix is to remove it and to rotate the real credential. Then apply the file and check:

```sh
kubectl -n catalog-source create configmap repo-shuttle --from-file=catalog-info.yaml --dry-run=client -o yaml | kubectl apply -f -
inspect_catalog -c '.summary'
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-030/module-01/labs/lab-01
```

The summary lists all three Components and `errorCount` is 0. Destroy the lab when you are done:

```sh
astrona destroy ats-071-lab-030-01
```
