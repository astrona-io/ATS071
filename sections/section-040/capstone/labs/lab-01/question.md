# Question

Solve this question on: `terminal`

The Starfleet platform team moved the descriptor files of the fleet into one tree. A root `Location` entity in the repository `registry` lists a teams file, a services file and one file in the repository `sensors`. The tree is not in the catalog yet, and one registration that already exists is broken. The catalog is modelled by ConfigMaps in the namespace `catalog-source`: each `repo-<name>` ConfigMap is one repository, and the ConfigMap `catalog-config` holds the `catalog:` key of the application configuration. The pod `deploy/catalog-tools` in `catalog-tools` checks them and prints one report. This is a model of the catalog backend, not the Backstage backend.

Bring the estate to this state:

1. The root file `catalog-info.yaml` of the repository `registry` (branch `main`) is registered in `catalog.locations`. Register only that file. The teams file, the services file and the sensors file must be reached through the `Location` entity.
2. The groups and the user in the teams file must be ingested, and the components that are already registered must stay ingested. Entities reached through a `Location` entity use only the global `catalog.rules`.
3. The component `sensor-array` in the repository `sensors` must be ingested.
4. The component `outpost-relay` must be declared once, in its own repository `outpost`. Remove the copy.
5. The component `old-sensors` is retired. It must no longer be declared anywhere. Keep the component `helm`.
6. Do not delete any repository ConfigMap, and keep the existing location of `outpost`. No relation may point at an entity that does not exist.

`kubectl` already points at the cluster as the cluster administrator. The tools pod runs `node /opt/check/inspect.js`, which reads the list of ConfigMaps as JSON on standard input.
