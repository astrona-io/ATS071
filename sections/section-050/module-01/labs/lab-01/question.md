# Question

Solve this question on: `terminal`

The Starfleet catalog reads six descriptor repositories through the static locations in the ConfigMap `catalog-config`. The inspector report shows that several entities that should be in the catalog are missing, and the report lists errors. The estate has five separate faults, and each one stops ingestion at a different point.

1. The `scout` Component must be ingested.
2. The `drifter` Component must be ingested.
3. The `probe` repository describes a Component. It must be ingested.
4. The `bridge` Component depends on the Resource `telemetry-db`. The Resource must be ingested, and no relation of `bridge` may point at an entity that is not ingested.
5. Two repositories declare the same entity reference. The `bridge` Component must stay with the `bridge` repository, and the `shuttle` repository must describe its own Component so that it is ingested too.

Find the cause of each fault in the report and repair it at its source. Do not delete repositories, locations or entities, and do not remove `catalog.rules`. The groups `starfleet-ops` and `scout-team`, the user `kira` and the `bridge` Component must stay ingested.

`kubectl` already points at the cluster. The ConfigMaps are in the namespace `catalog-source`. The inspector prints one JSON report. This function reads it:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```
