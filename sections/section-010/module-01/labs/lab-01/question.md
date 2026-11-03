# Question

Solve this question on: `terminal`

The Starfleet navigation estate is described in three descriptor repositories: `starfleet-org` (the teams), `bridge` (the bridge service, its API, its database and the `navigation` System) and `scout` (the scout website). The catalog reads them through the configuration in `catalog-config`. The report shows that the estate is not healthy: some entities are missing from the catalog and some relations point at entities that do not exist.

1. The `bridge` Component must be ingested and owned by the Group `starfleet-ops`.
2. The `bridge` Component must depend on the Resource `telemetry-db`, and that relation must resolve.
3. The API `bridge-api` must be part of the System `navigation`.
4. The `scout` Component must consume the API `bridge-api`, and that relation must resolve.
5. When you finish, the report must show zero errors and no unresolved relations.

Fix the descriptors in place. Do not delete repositories, entities or the catalog configuration, and do not change the system of the `bridge` Component. The helper below prints the report; save it in your shell first.

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

`kubectl` already points at the cluster as the cluster administrator.
