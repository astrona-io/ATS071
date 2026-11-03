# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab has not been run yet; the commands are checked statically only.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-020/capstone/labs/lab-01
```

`astrona submit` right after the start shows two passing checks. `catalog-intact` and `rogue-group-stays-blocked` pass because nothing has changed yet. They are your guards: they fail if you delete a repository, remove `Component` or `API` from the rules, or allow `Group` for every location.

## Step 1: Read the report

Paste the helper and list the errors with their stage:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
inspect_catalog -c '.errors[] | {entity, stage}'
```

Every error has the stage `rules`. The catalog configuration has a global `catalog.rules` list. A list that is present replaces the default list, so it must name every kind that the catalog accepts. The report does not list the `dock` repository at all, because no location points at it.

## Step 2: Change the catalog configuration

Three changes go in the key `app-config.yaml`. Add `System` and `Location` to the global list. Give the organization location its own `rules` entry that allows `Group` and `User`, because a rule on one location applies only to the file of that location. Add a location for the `dock` file. The ConfigMap below is the whole file:

Save this as `catalog-config.yaml`:

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
        - allow: [Component, API, System, Location]
      locations:
        - type: url
          target: https://git.starfleet.example/starfleet-org/blob/main/org.yaml
          rules:
            - allow: [Group, User]
        - type: url
          target: https://git.starfleet.example/ops/blob/main/catalog-info.yaml
        - type: url
          target: https://git.starfleet.example/harbor/blob/main/catalog-info.yaml
        - type: url
          target: https://git.starfleet.example/dock/blob/main/catalog-info.yaml
```

Apply it:

```sh
kubectl apply -f catalog-config.yaml
```

Submit:

```sh
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-020/capstone/labs/lab-01
```

`rules-allow-system-and-location`, `org-accepted-from-org-file` and `harbor-relations-resolve` pass. `rogue-group-stays-blocked` still passes, because the `Group` rule does not apply to the `harbor` file.

## Step 3: Read the new errors

The catalog now reads two more files. List the errors again:

```sh
inspect_catalog -c '.errors[] | {entity, stage, message}'
```

Four errors appear. One is the refused `rogue-admins` group, which is correct and stays. The others are: a `policy` error for the name `dock-gate-`, a `kind` error for the missing `lifecycle` of `dock-api`, and a `kind` error for the missing `owner` of `ops-gateway`. The `ops-gateway` file only appears because the `Location` entity is now accepted and the catalog follows its target.

## Step 4: Fix the descriptors

A name must end with a letter or a digit, so remove the trailing hyphen. Add the lifecycle to the API. Fix the `dock` file:

Save this as `repo-dock.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: repo-dock
  namespace: catalog-source
data:
  catalog-info.yaml: |
    apiVersion: backstage.io/v1alpha1
    kind: Component
    metadata:
      name: dock-gate
      description: Opens and closes the dock doors
    spec:
      type: service
      lifecycle: production
      owner: dockworkers
      providesApis: [dock-api]
    ---
    apiVersion: backstage.io/v1alpha1
    kind: API
    metadata:
      name: dock-api
    spec:
      type: openapi
      lifecycle: production
      owner: dockworkers
      definition: |
        openapi: 3.0.0
        info: {title: dock, version: "1"}
        paths: {}
```

Apply it:

```sh
kubectl apply -f repo-dock.yaml
```

Then add an owner to `ops-gateway`. The ConfigMap `repo-ops` has two keys, and the file below keeps both:

Save this as `repo-ops.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: repo-ops
  namespace: catalog-source
data:
  catalog-info.yaml: |
    apiVersion: backstage.io/v1alpha1
    kind: Location
    metadata:
      name: ops-index
      description: Lists the service files of the ops repository
    spec:
      targets:
        - ./services.yaml
  services.yaml: |
    apiVersion: backstage.io/v1alpha1
    kind: Component
    metadata:
      name: ops-gateway
      description: Entry point for the ops tools
    spec:
      type: service
      lifecycle: production
      owner: ops-team
```

Apply it:

```sh
kubectl apply -f repo-ops.yaml
```

Check what is left:

```sh
inspect_catalog -c '.errors[] | {entity, stage}'
```

Only the refused `rogue-admins` group remains, with the stage `rules`. That error is intended. Submit:

```sh
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-020/capstone/labs/lab-01
```

All checks pass. Destroy the lab when you are done:

```sh
astrona destroy ats-071-capstone-020
```
