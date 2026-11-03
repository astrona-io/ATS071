# Question

Solve this question on: `terminal`

The outpost catalog reads its descriptors from four sources that are registered as static locations in the ConfigMap `catalog-config`. One of them is a `Location` entity that points at the group and user files of the outpost. After the last change to the estate, most entities are missing from the catalog. The inspector report shows errors, a conflict and no usable ownership. Several faults exist at the same time, and they sit in different places: the configuration, the organization files and the descriptors of the services.

Repair the estate so that all of the following hold:

1. The groups `outpost-ops` and `drifters` are ingested.
2. The user `kira` is ingested through the `Location` entity.
3. The Component `sensor` is ingested.
4. The Component `beacon` is ingested and none of its relations points at an entity that is not ingested.
5. The Component `relay` is ingested.
6. No entity reference is declared by two locations. The API `beacon-api` stays with the `beacon` repository. The `relay` repository must describe its own API, which is ingested, and the `relay` Component must provide it.

Repair each fault where it is made. Do not delete repositories, locations or entities, and do not remove `catalog.rules`. The API `beacon-api`, the Resource `relay-db` and the `Location` entity `outpost-org` must stay ingested.

`kubectl` already points at the cluster. The ConfigMaps are in the namespace `catalog-source`. The inspector prints one JSON report. This function reads it:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```
