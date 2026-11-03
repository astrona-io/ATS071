# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab has not been run yet; the commands are checked statically only.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-040/capstone/labs/lab-01
```

`astrona submit` right after the start shows one passing check. `estate-intact` and `no-conflicts` pass because nothing is ingested yet and nothing is deleted. They are your guards: they fail if you delete a repository or the `outpost` registration.

## Step 1: Read the report

Define a helper that sends the ConfigMaps to the checker and prints the report through `jq`:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

Read the locations and the errors:

```sh
inspect_catalog -c '.locations[] | {target, origin, status}'
inspect_catalog -c '.errors[] | {stage, entity, message}'
```

Only the `outpost` file is read. Its component has an error in the stage `rules`, because the global `catalog.rules` list allows only `Group` and `User`. Nothing reads the `registry` repository, because no location points at it.

## Step 2: Register the root and fix the rules

Save the catalog configuration to a file:

```sh
kubectl -n catalog-source get configmap catalog-config -o yaml > catalog-config.yaml
```

Open `catalog-config.yaml`. Add a second item to `catalog.locations` with the target `https://git.starfleet.example/registry/blob/main/catalog-info.yaml`. Then change the rules list. A `catalog.rules` key replaces the default list, so it must name every kind that stays allowed:

```yaml
      rules:
        - allow: [Component, System, API, Resource, Location, Group, User]
```

Apply the file and read the report again:

```sh
kubectl apply -f catalog-config.yaml
inspect_catalog -c '.summary.ingested'
inspect_catalog -c '.errors[] | {stage, message}'
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-040/capstone/labs/lab-01
```

`registry-registered`, `groups-ingested` and `components-allowed` pass. A `rules` list on the root location would not help here: it applies only to entities read from that file, not to entities that the `Location` entity lists. The report now shows one fetch error for the `sensors` target and one conflict.

## Step 3: Fix the Location entity and the services file

The absolute target in the root `Location` entity uses the branch `master`, but the repository `sensors` has the default branch `main`. Save the three files of the `registry` repository:

```sh
kubectl -n catalog-source get configmap repo-registry -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
kubectl -n catalog-source get configmap repo-registry -o jsonpath='{.data.services\.yaml}' > services.yaml
```

In `catalog-info.yaml`, change `blob/master/` to `blob/main/`. In `services.yaml`, delete the whole `outpost-relay` document and the whole `old-sensors` document, with the `---` line before each. Only the `helm` document stays.

Write the two files back with a merge patch. A merge patch changes only the keys that it names, so `teams.yaml` stays:

```sh
kubectl -n catalog-source patch configmap repo-registry --type merge -p "$(jq -n --rawfile info catalog-info.yaml --rawfile services services.yaml '{data: {"catalog-info.yaml": $info, "services.yaml": $services}}')"
inspect_catalog -c '.conflicts'
inspect_catalog -c '[.entities[] | select(.ingested == true) | .ref]'
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-040/capstone/labs/lab-01
```

The conflicts list is empty and `sensor-array` is ingested. All checks pass. Destroy the lab when you are done:

```sh
astrona destroy ats-071-capstone-040
```
