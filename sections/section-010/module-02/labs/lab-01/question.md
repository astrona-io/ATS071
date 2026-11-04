# Question

Solve this question on: `terminal`

The Starfleet catalog lists five software entities, but its data is out of date. The descriptors are the ConfigMaps `repo-<name>` in the namespace `catalog-source`. `kubectl` already points at the cluster as the cluster administrator. Save the report helper in your shell first.

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

1. The `shuttle` Component must be ingested with the lifecycle `production`.
2. The `probe` Component is being retired. Its lifecycle must be the value that marks software as deprecated.
3. The `cargo-hauler` Component must be owned by the Group `starfleet-ops`, and the report must show no unresolved relations.

Do not delete any repository ConfigMap. Keep the `dependsOn` relation from `shuttle` to `probe`, and do not edit the ConfigMap `catalog-config`.
