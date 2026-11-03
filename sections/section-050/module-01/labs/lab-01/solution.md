# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab has not been run yet; the commands are checked statically only.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-050/module-01/labs/lab-01
```

`astrona submit` right after the start shows one passing check. `nothing-deleted` passes because nothing has changed yet. It is your guard.

## Step 1: Read the report

Define the helper function from the task. Then print the errors, the conflicts and the relations that point at missing entities:

```sh
inspect_catalog -c '{errors, conflicts, unresolved}'
```

Each item in `errors` has a `stage`: `fetch`, `parse`, `policy` or `rules`. Conflicts and unresolved relations are listed separately, because they are not errors of one entity. Read all of it before you change anything. Then print which locations were read and what happened to each:

```sh
inspect_catalog -c '.locations[] | {target, status}'
```

One location has the status `not-found`.

## Step 2: Fix the fetch error (scout)

The location URL ends in `blob/master/`, but the repository ConfigMap has no `astrona.io/default-branch` annotation, so its default branch is `main`. The location is in `catalog-config`. Save the corrected ConfigMap. It also allows the kind `Resource`, which you need in Step 5:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: catalog-config
  namespace: catalog-source
data:
  app-config.yaml: |
    catalog:
      rules:
        - allow: [Component, System, API, Resource, Group, User, Location]
      locations:
        - type: url
          target: https://git.starfleet.example/starfleet-org/blob/main/org.yaml
        - type: url
          target: https://git.starfleet.example/bridge/blob/main/catalog-info.yaml
        - type: url
          target: https://git.starfleet.example/scout/blob/main/catalog-info.yaml
        - type: url
          target: https://git.starfleet.example/probe/blob/main/catalog-info.yaml
        - type: url
          target: https://git.starfleet.example/drifter/blob/main/catalog-info.yaml
        - type: url
          target: https://git.starfleet.example/shuttle/blob/main/catalog-info.yaml
```

Apply it:

```sh
kubectl apply -f catalog-config.yaml
```

Then check the location status again and submit:

```sh
inspect_catalog -c '.locations[] | select(.status != "ok") | .target'
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-050/module-01/labs/lab-01
```

The location `scout` is read now, and `scout-fetched` passes. The `bridge-dependency-resolves` check passes too, because the rules change also covers Step 5.

## Step 3: Fix the parse error (drifter)

The parse error names line 5, column 16 of the `drifter` file. The line is the `description`. A colon followed by a space inside an unquoted value starts a nested mapping, which YAML does not allow there. Quote the value. Save the ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: repo-drifter
  namespace: catalog-source
data:
  catalog-info.yaml: |
    apiVersion: backstage.io/v1alpha1
    kind: Component
    metadata:
      name: drifter
      description: "Reaches the probe: always through the bridge"
    spec:
      type: service
      lifecycle: experimental
      owner: scout-team
```

Apply it and submit:

```sh
kubectl apply -f repo-drifter.yaml
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-050/module-01/labs/lab-01
```

`drifter-parsed` passes.

## Step 4: Fix the policy error (probe)

The policy error says that `metadata.name` may contain only letters, digits and the separators `-`, `_` and `.`. The name `Probe Service` has a space and capital letters. Use `probe`. The human-readable text belongs in `description` or `title`. Save the ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: repo-probe
  namespace: catalog-source
data:
  catalog-info.yaml: |
    apiVersion: backstage.io/v1alpha1
    kind: Component
    metadata:
      name: probe
      description: Collects telemetry from the scout
    spec:
      type: service
      lifecycle: production
      owner: starfleet-ops
```

Apply it and submit:

```sh
kubectl apply -f repo-probe.yaml
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-050/module-01/labs/lab-01
```

`probe-valid` passes.

## Step 5: Fix the rules error (telemetry-db)

The `telemetry-db` Resource is valid, but the catalog rules do not allow the kind `Resource`. The rules error is also the reason for the unresolved `dependsOn` relation of `bridge`. The ConfigMap you applied in Step 2 added `Resource` to `catalog.rules`. Confirm that the Resource is ingested and that no relation is unresolved for `bridge`:

```sh
inspect_catalog -c '.summary.ingested, .unresolved'
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-050/module-01/labs/lab-01
```

`bridge-dependency-resolves` passes. If it fails, the ConfigMap from Step 2 was not applied.

## Step 6: Fix the identity conflict (shuttle)

The `shuttle` repository declares a Component named `bridge`. The catalog keeps one entity per reference and takes the first location that claims it. The `shuttle` repository does not appear in `errors` at all. Only the `conflicts` list shows the problem. Give the entity its own name. Save the ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: repo-shuttle
  namespace: catalog-source
data:
  catalog-info.yaml: |
    apiVersion: backstage.io/v1alpha1
    kind: Component
    metadata:
      name: shuttle
      description: Carries crew between the bridge and the scout
    spec:
      type: service
      lifecycle: production
      owner: starfleet-ops
```

Apply it and submit:

```sh
kubectl apply -f repo-shuttle.yaml
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-050/module-01/labs/lab-01
```

`shuttle-no-conflict` passes, and all six checks pass. Print the final report to see an empty `errors`, `conflicts` and `unresolved`:

```sh
inspect_catalog -c '{errors, conflicts, unresolved}'
```

Destroy the lab when you are done:

```sh
astrona destroy ats-071-lab-050-01
```
