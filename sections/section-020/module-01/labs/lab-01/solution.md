# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab has not been run yet; the commands are checked statically only.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-020/module-01/labs/lab-01
```

`astrona submit` right after the start shows one passing check. `catalog-intact` passes because nothing has changed yet. It is your guard: it fails if you delete a repository or a location, or if you add `catalog.rules`.

## Step 1: Read the report

Paste the helper, then list every error with its stage:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
inspect_catalog -c '.errors[] | {entity, stage, message}'
```

Six errors appear. The `kind` stage means a required field of the kind is missing. The `policy` stage means a field breaks a format rule or the envelope has a field that is not allowed. The `parse` stage means the YAML text cannot be read, so it has no entity name.

## Step 2: Fix the group

The `starfleet-ops` document has no `spec.children`. A Group requires the field, and an empty list is valid. The ConfigMap below is the whole organization file with the field added. It replaces the key `org.yaml`:

Save this as `repo-starfleet-org.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: repo-starfleet-org
  namespace: catalog-source
data:
  org.yaml: |
    apiVersion: backstage.io/v1alpha1
    kind: Group
    metadata:
      name: starfleet-ops
      description: Operates the fleet services
    spec:
      type: team
      children: []
    ---
    apiVersion: backstage.io/v1alpha1
    kind: Group
    metadata:
      name: scout-team
    spec:
      type: team
      children: []
    ---
    apiVersion: backstage.io/v1alpha1
    kind: User
    metadata:
      name: kira
    spec:
      memberOf: [starfleet-ops]
```

Apply it:

```sh
kubectl apply -f repo-starfleet-org.yaml
```

Submit:

```sh
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-020/module-01/labs/lab-01
```

`org-groups-valid` now passes. The `unresolved` entry for `kira` disappears because its target is now accepted.

## Step 3: Fix the telemetry name and the relay lifecycle

A name may contain letters, digits, `-`, `_` and `.`, but not a space. Replace the space with a hyphen. The `relay` Component needs `spec.lifecycle`. Fix the first file:

Save this as `repo-telemetry.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: repo-telemetry
  namespace: catalog-source
data:
  catalog-info.yaml: |
    apiVersion: backstage.io/v1alpha1
    kind: Component
    metadata:
      name: probe-telemetry
      description: Receives readings from the probe
    spec:
      type: service
      lifecycle: production
      owner: starfleet-ops
```

Apply it:

```sh
kubectl apply -f repo-telemetry.yaml
```

Then the second file:

Save this as `repo-relay.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: repo-relay
  namespace: catalog-source
data:
  catalog-info.yaml: |
    apiVersion: backstage.io/v1alpha1
    kind: Component
    metadata:
      name: relay
      description: Forwards messages between ships
    spec:
      type: service
      lifecycle: production
      owner: starfleet-ops
```

Apply it:

```sh
kubectl apply -f repo-relay.yaml
```

Submit:

```sh
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-020/module-01/labs/lab-01
```

`telemetry-accepted` and `relay-has-lifecycle` pass.

## Step 4: Fix the two faults in the cargo file

The `cargo` Component has a root field `team`. A descriptor allows only the envelope fields at the root, so the field must go. Owners belong in `spec.owner`, which is already set. The `cargo-api` API has no `spec.definition`. Give it a short OpenAPI text. This is one ConfigMap with both fixes:

Save this as `repo-cargo.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: repo-cargo
  namespace: catalog-source
data:
  catalog-info.yaml: |
    apiVersion: backstage.io/v1alpha1
    kind: Component
    metadata:
      name: cargo
      description: Tracks the cargo of each ship
    spec:
      type: service
      lifecycle: production
      owner: starfleet-ops
      providesApis: [cargo-api]
    ---
    apiVersion: backstage.io/v1alpha1
    kind: API
    metadata:
      name: cargo-api
    spec:
      type: openapi
      lifecycle: production
      owner: starfleet-ops
      definition: |
        openapi: 3.0.0
        info: {title: cargo, version: "1"}
        paths: {}
```

Apply it:

```sh
kubectl apply -f repo-cargo.yaml
```

Submit:

```sh
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-020/module-01/labs/lab-01
```

`cargo-entities-accepted` passes. The reference `providesApis: [cargo-api]` resolves once the API is accepted.

## Step 5: Fix the scanner indentation

The line `owner: starfleet-ops` has one space too many, so the YAML parser cannot read the mapping. All keys of `spec` need the same indentation:

Save this as `repo-scanner.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: repo-scanner
  namespace: catalog-source
data:
  catalog-info.yaml: |
    apiVersion: backstage.io/v1alpha1
    kind: Component
    metadata:
      name: scanner
      description: Scans nearby space
    spec:
      type: service
      lifecycle: production
      owner: starfleet-ops
```

Apply it:

```sh
kubectl apply -f repo-scanner.yaml
```

Check that the report has no errors:

```sh
inspect_catalog -c '.errors'
```

The result is an empty list, `[]`. Submit:

```sh
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-020/module-01/labs/lab-01
```

All checks pass. Destroy the lab when you are done:

```sh
astrona destroy ats-071-lab-020-01
```
