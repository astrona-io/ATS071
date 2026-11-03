# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab has not been run yet; the commands are checked statically only.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-040/module-01/labs/lab-01
```

`astrona submit` right after the start shows one passing check. `bridge-untouched` passes because nothing has changed yet. It is your guard: it fails if you delete a repository or break `bridge`.

## Step 1: Read the report

Define a helper that sends the ConfigMaps to the checker and prints the report through `jq`:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

List every location the checker tried to read and the errors it found:

```sh
inspect_catalog -c '.locations[] | {target, origin, status}'
inspect_catalog -c '.errors[] | {stage, location, entity}'
```

Two locations have the status `not-found`. Three groups and a user have errors in the stage `rules`. The `origin` of a location is `config` when it comes from `catalog.locations`, and it is the URL of a file when a `Location` entity listed it.

## Step 2: Fix the scout location

A target has the form `https://git.starfleet.example/<repo>/blob/<branch>/<file>`. The branch must equal the annotation `astrona.io/default-branch` of the repository ConfigMap, or `main` when there is no annotation. Read the annotations of `repo-scout`:

```sh
kubectl -n catalog-source get configmap repo-scout -o jsonpath='{.metadata.annotations}'
```

There is no annotation, so the branch is `main`, and the registered target uses `master`. Save the catalog configuration to a file:

```sh
kubectl -n catalog-source get configmap catalog-config -o yaml > catalog-config.yaml
```

Open `catalog-config.yaml` and change `blob/master/` to `blob/main/` in the `scout` target. Apply the file and check:

```sh
kubectl apply -f catalog-config.yaml
inspect_catalog -c '.locations[] | select(.target | test("scout")) | .status'
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-040/module-01/labs/lab-01
```

`scout-ingested` now passes. If `kubectl` complains about `resourceVersion` or `uid`, delete those lines from the file and apply it again.

## Step 3: Allow the kinds on one location

The default rules allow `Component`, `System`, `API`, `Resource` and `Location`. They do not allow `Group` or `User`. A `rules` list on a single location adds kinds for the file at that location only. In `catalog-config.yaml`, add this under the `starfleet-org` location, at the same indentation as `target`:

```yaml
          rules:
            - allow: [Group, User]
```

Apply the file again and check which entities are ingested:

```sh
kubectl apply -f catalog-config.yaml
inspect_catalog -c '.summary.ingested'
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-040/module-01/labs/lab-01
```

`org-entities-ingested` and `global-rules-unchanged` pass. A global `catalog.rules` key would also have allowed the kinds, but it would replace the defaults for every location, so the check rejects it.

## Step 4: Fix the Location entity target

The `Location` entity lists `./shuttle.yaml` and `./cargo.yml`. The relative path resolves against the file that holds the entity. The repository has the key `cargo.yaml`, not `cargo.yml`. Save the file text:

```sh
kubectl -n catalog-source get configmap repo-fleet-registry -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
```

Change `./cargo.yml` to `./cargo.yaml` in `catalog-info.yaml`. Write the file text back into the one key with a merge patch. A merge patch changes only the keys that it names, so `shuttle.yaml` and `cargo.yaml` stay:

```sh
kubectl -n catalog-source patch configmap repo-fleet-registry --type merge -p "$(jq -n --rawfile text catalog-info.yaml '{data: {"catalog-info.yaml": $text}}')"
inspect_catalog -c '.summary.ingested'
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-040/module-01/labs/lab-01
```

`fleet-components-ingested` passes.

## Step 5: Retire the probe

The component `probe` comes from the location for `legacy-probe` in `catalog.locations`. Remove that list item from `catalog-config.yaml` (the two lines with `- type: url` and `target` for `legacy-probe`) and apply the file. Do not delete the ConfigMap `repo-legacy-probe`: the source stays, only the registration goes.

```sh
kubectl apply -f catalog-config.yaml
inspect_catalog -c '[.entities[] | select(.name == "probe")] | length'
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS071.git -c sections/section-040/module-01/labs/lab-01
```

The count is `0`. All checks pass, including `no-fetch-errors` and `probe-retired`. Destroy the lab when you are done:

```sh
astrona destroy ats-071-lab-040-01
```
