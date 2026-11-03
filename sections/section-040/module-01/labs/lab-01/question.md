# Question

Solve this question on: `terminal`

The Starfleet platform team registers five descriptor repositories by hand in the catalog configuration. After the last change, several entities are missing from the catalog. The catalog is modelled by ConfigMaps in the namespace `catalog-source`: each `repo-<name>` ConfigMap is one repository, and the ConfigMap `catalog-config` holds the `catalog:` key of the application configuration. The pod `deploy/catalog-tools` in `catalog-tools` checks them and prints a report. This is a model of the catalog backend, not the Backstage backend.

Make these changes:

1. The component `scout` must be ingested. Its repository exists, but its registered location does not resolve.
2. The three groups and the user in the file `org.yaml` of the repository `starfleet-org` must be ingested. They must be allowed by a `rules` list on that one location. Do not add a global `catalog.rules` key.
3. The `Location` entity in the repository `fleet-registry` lists two descriptor files. Both components, `shuttle` and `cargo-hauler`, must be ingested through that `Location` entity. Do not register the two files in `catalog.locations`.
4. The service `probe` is retired. It must no longer be in the catalog. Do not delete its repository.
5. No location may fail to fetch, and the component `bridge` and every other repository must stay as they are.

`kubectl` already points at the cluster as the cluster administrator. The tools pod runs `node /opt/check/inspect.js`, which reads the list of ConfigMaps as JSON on standard input.
