# Question

Solve this question on: `terminal`

The Starfleet platform team registered five repositories and an organization file in the catalog. The catalog configuration is correct and must stay as it is. Several descriptor files are rejected, so some entities are missing from the catalog. Descriptors are the ConfigMaps `repo-<name>` in the namespace `catalog-source`, and the catalog configuration is the ConfigMap `catalog-config`.

1. The group `starfleet-ops` must be accepted by the catalog, and the user `kira` must be able to resolve its `memberOf` reference to it.
2. The Component in the `telemetry` repository must be accepted under the name `probe-telemetry`. Keep its owner.
3. The Component `relay` must be accepted with the lifecycle `production`.
4. The Component `cargo` and the API `cargo-api` must both be accepted, and the API that `cargo` provides must resolve.
5. The Component `scanner` must be accepted. Its file must parse without errors.
6. Keep every repository and every location. Do not add `catalog.rules` and do not change the locations. The Component `scout` must stay accepted.

Do not delete a document to make an error disappear. Fix the document. When you finish, the report of the inspector must show no error for the five repositories.

`kubectl` already points at the cluster as the cluster administrator. The catalog is a model: it checks descriptors with the `@backstage/catalog-model` library and does not run Backstage.
