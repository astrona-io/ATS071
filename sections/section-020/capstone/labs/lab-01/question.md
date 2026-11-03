# Question

Solve this question on: `terminal`

The Starfleet platform team restricted the catalog to a short list of kinds and then added four repositories. Many entities are missing, one repository is not read at all and the catalog configuration has gaps. The descriptor repositories are the ConfigMaps `repo-<name>` in the namespace `catalog-source`, and the catalog configuration is the ConfigMap `catalog-config`.

1. The `System` and `Location` entities must be accepted. The kinds `Component` and `API` must stay allowed.
2. The groups and the user in the organization file must be accepted. A `Group` must be accepted only from that file. The `Group` named `rogue-admins` in the `harbor` repository must stay refused.
3. The Component `harbor-control` must be accepted and every relation it declares must resolve.
4. The `dock` repository must be a configured location. The Component `dock-gate` and the API `dock-api` must both be accepted, and the API that `dock-gate` provides must resolve.
5. The Location entity in the `ops` repository lists another file. That file must be read and the Component `ops-gateway` in it must be accepted.
6. Keep every repository. Do not delete a document to make an error disappear.

`kubectl` already points at the cluster as the cluster administrator. The catalog is a model: it checks descriptors with the `@backstage/catalog-model` library and does not run Backstage.
