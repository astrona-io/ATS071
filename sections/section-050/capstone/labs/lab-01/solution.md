# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab has not been run yet; the commands are checked statically only.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-050/capstone/labs/lab-01
```

`astrona submit` right after the start shows one passing check. `nothing-deleted` passes because nothing has changed yet. It is your guard.

## Step 1: Group the evidence by stage

Define the helper function from the task. Then print the errors with their stage, the conflicts and the unresolved relations:

```sh
inspect_catalog -c '{errors: [.errors[] | {stage, entity, location}], conflicts, unresolved}'
```

The report holds six errors in five stages and one conflict: a `rules` error for a Group, a `kind` error for a Group, a `relations` error for `beacon`, a `policy` error for `relay`, two `fetch` errors and the conflict on `api:default/beacon-api`. Print the locations too. A location that came from the `Location` entity has the `origin` of its parent file:

```sh
inspect_catalog -c '.locations[] | {target, origin, status}'
```

## Step 2: Fix the configuration

Two faults are in `catalog-config`. The rules allow no `Group` or `User`. The rules of a `Location` entity do not apply to the entities it reaches, so the global rules decide. The `sensor` location also uses the type `file`, and no reader is available for it. Use a `url` location. Save the corrected ConfigMap:

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
          target: https://git.starfleet.example/outpost-org/blob/main/catalog-info.yaml
        - type: url
          target: https://git.starfleet.example/beacon/blob/main/catalog-info.yaml
        - type: url
          target: https://git.starfleet.example/relay/blob/main/catalog-info.yaml
        - type: url
          target: https://git.starfleet.example/sensor/blob/main/catalog-info.yaml
```

Apply it:

```sh
kubectl apply -f catalog-config.yaml
```

Then check the report and submit:

```sh
inspect_catalog -c '.locations[] | select(.status != "ok") | {target, status}'
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-050/capstone/labs/lab-01
```

The `sensor` location is read now, and `org-kinds-allowed` and `sensor-registered` pass.

## Step 3: Fix the organization files

The `drifters` group has no `spec.children`, and the `Location` entity lists `./user.yaml` while the file is called `users.yaml`. Save the ConfigMap with both repairs:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: repo-outpost-org
  namespace: catalog-source
data:
  catalog-info.yaml: |
    apiVersion: backstage.io/v1alpha1
    kind: Location
    metadata:
      name: outpost-org
      description: Groups and users of the outpost
    spec:
      targets:
        - ./groups.yaml
        - ./users.yaml
  groups.yaml: |
    apiVersion: backstage.io/v1alpha1
    kind: Group
    metadata:
      name: outpost-ops
    spec:
      type: team
      children: [drifters]
    ---
    apiVersion: backstage.io/v1alpha1
    kind: Group
    metadata:
      name: drifters
    spec:
      type: team
      parent: outpost-ops
      children: []
  users.yaml: |
    apiVersion: backstage.io/v1alpha1
    kind: User
    metadata:
      name: kira
    spec:
      memberOf: [outpost-ops]
```

Apply it and submit:

```sh
kubectl apply -f repo-outpost-org.yaml
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-050/capstone/labs/lab-01
```

`drifters-group-valid` and `users-location-reachable` pass.

## Step 4: Fix the beacon relation

The `dependsOn` entry `relay-db` has no kind. A relation target needs the kind when the field accepts more than one kind. Write `resource:default/relay-db`. Save the ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: repo-beacon
  namespace: catalog-source
data:
  catalog-info.yaml: |
    apiVersion: backstage.io/v1alpha1
    kind: Component
    metadata:
      name: beacon
      description: Sends position reports
    spec:
      type: service
      lifecycle: production
      owner: outpost-ops
      providesApis: [beacon-api]
      dependsOn: [resource:default/relay-db]
    ---
    apiVersion: backstage.io/v1alpha1
    kind: API
    metadata:
      name: beacon-api
    spec:
      type: openapi
      lifecycle: production
      owner: outpost-ops
      definition: "openapi: 3.0.0"
    ---
    apiVersion: backstage.io/v1alpha1
    kind: Resource
    metadata:
      name: relay-db
    spec:
      type: database
      owner: outpost-ops
```

Apply it and submit:

```sh
kubectl apply -f repo-beacon.yaml
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-050/capstone/labs/lab-01
```

`beacon-dependency-resolves` passes.

## Step 5: Fix the relay descriptor and the conflict

The label value `Outpost Ops` has a space, which label values do not allow. The `relay` repository also declares the API `beacon-api`, which the `beacon` repository already declares. The first location that claims a reference keeps it. Rename the API of `relay` to `relay-api` and let the Component provide it. Save the ConfigMap:

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
      description: Forwards position reports
      labels:
        team: outpost-ops
    spec:
      type: service
      lifecycle: production
      owner: drifters
      providesApis: [relay-api]
    ---
    apiVersion: backstage.io/v1alpha1
    kind: API
    metadata:
      name: relay-api
    spec:
      type: openapi
      lifecycle: production
      owner: drifters
      definition: "openapi: 3.0.0"
```

Apply it and submit:

```sh
kubectl apply -f repo-relay.yaml
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-050/capstone/labs/lab-01
```

`relay-valid` and `api-single-owner` pass, and all eight checks pass. Print the final report to see an empty `errors`, `conflicts` and `unresolved`:

```sh
inspect_catalog -c '{errors, conflicts, unresolved}'
```

Destroy the lab when you are done:

```sh
astrona destroy ats-071-capstone-050
```
