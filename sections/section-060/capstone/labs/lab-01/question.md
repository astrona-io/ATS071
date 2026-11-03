Solve this question on: `terminal`

# Automated Ingestion Capstone

Starfleet moves its catalog from hand-registered locations to GitHub discovery. The migration is half done. The provider `starfleetServices` is configured for the organization `starfleet`, one static location from the old setup is still there, and the report of the catalog model is not clean. You must finish the migration without widening what the provider may read.

The environment is a kind cluster, not the Backstage application. The eight repositories of the organization are ConfigMaps named `repo-<name>` in the namespace `catalog-source`, and their annotations carry the topics, visibility, default branch and organization. The catalog configuration is the ConfigMap `catalog-config` with the key `app-config.yaml`. The pod `deploy/catalog-tools` in `catalog-tools` runs `node /opt/check/inspect.js` and prints a JSON report. The report models the catalog backend, not the Backstage backend.

Requirements:

1. The provider `starfleetServices` discovers the repositories `bridge`, `scout` and `shuttle` through the file `catalog-info.yaml` on the branch `main`, and the Components are ingested.
2. The repository `crew-directory` holds the Group and User entities. They are discovered by the same provider and ingested, and every owner of every Component resolves.
3. The Component `scout` is declared in two files. It is read once, from `catalog-info.yaml`, by the provider. There are no conflicts.
4. These repositories are not discovered, each for its own reason: `vault` (private), `sandbox-test` (the name starts with `sandbox-`), `deprecated-relay` (topic `deprecated`) and `hangar-legacy` (default branch `master`). Public and internal repositories with the topic `catalog` are in scope.
5. The provider does not run more often than every 15 minutes. The schedule has a `frequency` written as an object, and a `timeout`.
6. The final report has no errors and the catalog has six entities: three Components, two Groups and one User.
7. Keep the organization `starfleet` and the branch filter `main`. Do not change or delete any `repo-*` ConfigMap.

Check your work with `astrona submit`.
