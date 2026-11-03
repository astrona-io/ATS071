# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab has not been run yet; the commands are checked statically only.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-060/module-01/labs/lab-01
```

Paste the helper that prints the report of the catalog model:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

`astrona submit` right after the start shows one passing check. `scope-not-widened` passes because nothing has changed yet. It is your guard: it fails if you remove the organization, the branch or a repository to make other checks pass.

## Step 1: Read what the provider produced

List the locations that the provider created and the entities that entered the catalog:

```sh
inspect_catalog -c '{providerLocations: [.locations[] | select(.origin | startswith("provider"))], ingested: .summary.ingested}'
```

The list of provider locations is empty. Only the teams from the static location are ingested. A provider creates a location only for a repository that passes every filter, so a filter or the organization removes all eight repositories. Print the provider configuration to see the filters:

```sh
inspect_catalog '.config.providers.github'
```

## Step 2: Fix the branch and the catalog path

The repositories use the branch `main` and the file `catalog-info.yaml`. The provider asks for the branch `develop` and the file `catalog.yaml`. Save the corrected configuration as `configmap-catalog-config.yaml`. It keeps the other faults on purpose, so you can see each one appear:

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
        - allow: [Component, System, API, Resource, Location, Group, User]
      locations:
        - type: url
          target: https://git.starfleet.example/starfleet-org/blob/main/org.yaml
      providers:
        github:
          starfleetServices:
            organization: starfleet
            catalogPath: /catalog-info.yaml
            filters:
              branch: main
              topic:
                include: [catalog]
              visibility: [public]
            schedule:
              frequency: { seconds: 20 }
              timeout: { minutes: 3 }
```

Apply it:

```sh
kubectl apply -f configmap-catalog-config.yaml
```

Then check the result:

```sh
inspect_catalog -c '[.locations[] | select(.origin | startswith("provider")) | {target, status}]'
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-060/module-01/labs/lab-01
```

The provider now has locations and they are found, so `provider-locations-resolve` passes. `public-services-ingested` passes too. The list also shows `probe`, which must not be there.

## Step 3: Narrow and widen the scope

Two filters need a change. The topic `experiment` must be excluded, because exclusion removes a repository even when it carries the topic `catalog`. The visibility list must contain `internal` as well, because `bridge` is an internal repository. Keep `private` out of the list so that `vault` is never discovered. Save the file again as `configmap-catalog-config.yaml`:

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
        - allow: [Component, System, API, Resource, Location, Group, User]
      locations:
        - type: url
          target: https://git.starfleet.example/starfleet-org/blob/main/org.yaml
      providers:
        github:
          starfleetServices:
            organization: starfleet
            catalogPath: /catalog-info.yaml
            filters:
              branch: main
              topic:
                include: [catalog]
                exclude: [experiment]
              visibility: [public, internal]
            schedule:
              frequency: { seconds: 20 }
              timeout: { minutes: 3 }
```

Apply it:

```sh
kubectl apply -f configmap-catalog-config.yaml
```

Then check the result:

```sh
inspect_catalog '.summary.ingested'
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-060/module-01/labs/lab-01
```

`bridge`, `scout` and `shuttle` are ingested, and `probe` and `vault` are not. `experiment-excluded` and `private-repo-not-discovered` pass.

## Step 4: Slow the schedule down

A frequency of 20 seconds makes the backend call GitHub for every repository 180 times an hour, which wastes the rate limit. Change the frequency to 30 minutes. Save the final file as `configmap-catalog-config.yaml`:

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
        - allow: [Component, System, API, Resource, Location, Group, User]
      locations:
        - type: url
          target: https://git.starfleet.example/starfleet-org/blob/main/org.yaml
      providers:
        github:
          starfleetServices:
            organization: starfleet
            catalogPath: /catalog-info.yaml
            filters:
              branch: main
              topic:
                include: [catalog]
                exclude: [experiment]
              visibility: [public, internal]
            schedule:
              frequency: { minutes: 30 }
              timeout: { minutes: 3 }
```

Apply it and submit:

```sh
kubectl apply -f configmap-catalog-config.yaml
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-060/module-01/labs/lab-01
```

All six checks pass. `hangar-legacy` and `outpost-relay` stay out because the branch filter and the organization still exclude them. Destroy the lab when you are done:

```sh
astrona destroy ats-071-lab-060-01
```
