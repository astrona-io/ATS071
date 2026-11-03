# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab has not been run yet; the commands are checked statically only.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-060/capstone/labs/lab-01
```

Paste the helper that prints the report of the catalog model:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

`astrona submit` right after the start shows one passing check. `provider-config-kept` passes because the organization, the branch filter and the repositories are all still there. It is your guard.

## Step 1: Read the configuration

Print the catalog section and the locations that exist:

```sh
inspect_catalog -c '{config: .config, locations: [.locations[] | {origin, target, status}]}'
```

Only the static location for `legacy-info.yaml` exists. The provider creates no location. Two filters explain this. The topic list asks for `backstage`, but the repositories carry `catalog`. The repository filter `^svc-.*` matches no repository name. Fix these first, because the later problems only show once the provider finds something.

## Step 2: Fix the filters

Save this as `configmap-catalog-config.yaml`. The name filter is a regular expression with a negative look-ahead, which rejects every name that starts with `sandbox-`. The topic filter excludes `deprecated` and the visibility list leaves out `private`. The static location and the old rules stay on purpose for now:

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
        - allow: [Component, System, API, Resource, Location]
      locations:
        - type: url
          target: https://git.starfleet.example/scout/blob/main/legacy-info.yaml
      providers:
        github:
          starfleetServices:
            organization: starfleet
            catalogPath: /catalog-info.yaml
            filters:
              branch: main
              repository: '^(?!sandbox-)'
              topic:
                include: [catalog]
                exclude: [deprecated]
              visibility: [public, internal]
            schedule:
              frequency: { seconds: 30 }
              timeout: { minutes: 3 }
```

Apply it:

```sh
kubectl apply -f configmap-catalog-config.yaml
```

Then read the new problems:

```sh
inspect_catalog -c '{conflicts: .conflicts, errors: [.errors[] | .stage + ": " + .message]}'
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-060/capstone/labs/lab-01
```

The report now lists a conflict for `component:default/scout` and three rules errors for the entities of the kinds Group and User. `excluded-repos-not-discovered` passes.

## Step 3: Remove the duplicate and allow the missing kinds

The static location and the provider both read a file that declares `scout`. The static location is listed first, so it wins and the provider copy loses. The provider is the intended source, so delete the static location. The default rules do not allow Group or User, and a list in `catalog.rules` replaces the defaults, so add both kinds. Save the file again as `configmap-catalog-config.yaml`:

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
      providers:
        github:
          starfleetServices:
            organization: starfleet
            catalogPath: /catalog-info.yaml
            filters:
              branch: main
              repository: '^(?!sandbox-)'
              topic:
                include: [catalog]
                exclude: [deprecated]
              visibility: [public, internal]
            schedule:
              frequency: { seconds: 30 }
              timeout: { minutes: 3 }
```

Apply it:

```sh
kubectl apply -f configmap-catalog-config.yaml
```

Then check the result:

```sh
inspect_catalog -c '{conflicts: .conflicts, unresolved: .unresolved, errors: .errors}'
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-060/capstone/labs/lab-01
```

The conflict list, the unresolved list and the error list are empty. `services-discovered`, `groups-ingested`, `no-duplicate-claims` and `no-processing-errors` pass.

## Step 4: Slow the schedule down

A frequency of 30 seconds is far too often for a provider that makes one GitHub request per repository. Use 30 minutes. Save the final file as `configmap-catalog-config.yaml`:

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
      providers:
        github:
          starfleetServices:
            organization: starfleet
            catalogPath: /catalog-info.yaml
            filters:
              branch: main
              repository: '^(?!sandbox-)'
              topic:
                include: [catalog]
                exclude: [deprecated]
              visibility: [public, internal]
            schedule:
              frequency: { minutes: 30 }
              timeout: { minutes: 3 }
```

Apply it and submit:

```sh
kubectl apply -f configmap-catalog-config.yaml
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-060/capstone/labs/lab-01
```

All seven checks pass. Destroy the lab when you are done:

```sh
astrona destroy ats-071-capstone-060
```
