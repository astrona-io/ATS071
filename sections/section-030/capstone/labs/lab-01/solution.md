# Solution

Solve this lab on `terminal`. This lab has not been run yet; the commands are checked statically only. The guard check (`validate-estate-intact.sh`) already passes before you change anything. It fails only if you delete a repository or break an annotation that was correct.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-030/capstone/labs/lab-01
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

Two entities fail. `probe` fails the policy stage because of an annotation key that contains spaces. `shuttle` fails the kind stage because `spec.lifecycle` is missing: the value sits in an annotation instead. The other mistakes produce no error, because the values are valid strings. You find them by reading the annotations.

```sh
inspect_catalog -c '.entities[] | select(.valid == true and .kind == "Component") | {ref, annotations: .metadata.annotations}'
```

## Step 2: Fix probe

Annotation keys are an optional prefix, a slash and a name that uses letters, digits and `-_.`. A space is not allowed. Save the descriptor, edit it, and apply it:

```sh
kubectl -n catalog-source get configmap repo-probe -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
```

In the file, rename the key `on call/schedule` to `example.com/oncall-schedule` and delete the `example.com/api-password` line. Then apply it:

```sh
kubectl -n catalog-source create configmap repo-probe --from-file=catalog-info.yaml --dry-run=client -o yaml | kubectl apply -f -
inspect_catalog -c '.entities[] | select(.ref == "component:default/probe") | {ingested, annotations: .metadata.annotations}'
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-030/capstone/labs/lab-01
```

## Step 3: Fix bridge and scout

For `bridge`, change `github.com/project-slug` from the web address to `starfleet-org/bridge`. For `scout`, add `backstage.io/techdocs-ref: dir:.` and change `backstage.io/source-location` to `url:https://git.starfleet.example/scout/tree/main/`. The `url:` prefix and the trailing slash both matter: the value is a location reference and the slash marks a folder.

```sh
kubectl -n catalog-source get configmap repo-bridge -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
```

Edit the file, then apply it:

```sh
kubectl -n catalog-source create configmap repo-bridge --from-file=catalog-info.yaml --dry-run=client -o yaml | kubectl apply -f -
```

Do the same for `scout`: save its file, edit it and apply it with `repo-scout` in both commands. Then check:

```sh
inspect_catalog -c '.entities[] | select(.ref == "component:default/bridge" or .ref == "component:default/scout") | {ref, annotations: .metadata.annotations}'
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-030/capstone/labs/lab-01
```

## Step 4: Fix shuttle

Set the three copied annotations to `starfleet-org/shuttle`, `shuttle` and `https://git.starfleet.example/shuttle/blob/main/catalog-info.yaml`. Remove the `example.com/lifecycle` annotation and add `lifecycle: production` under `spec`.

```sh
kubectl -n catalog-source get configmap repo-shuttle -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
```

Edit the file, then apply it:

```sh
kubectl -n catalog-source create configmap repo-shuttle --from-file=catalog-info.yaml --dry-run=client -o yaml | kubectl apply -f -
inspect_catalog -c '.summary'
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-030/capstone/labs/lab-01
```

The summary lists all four Components and both Groups, and `errorCount` is 0. Destroy the lab when you are done:

```sh
astrona destroy ats-071-capstone-030
```
