Solve this question on: `terminal`

# Fix GitHub Discovery Filters

The Starfleet platform team keeps its descriptor files in eight GitHub repositories of the organization `starfleet`. The team switched on GitHub discovery with the provider `starfleetServices` in the catalog configuration, so that repositories with the topic `catalog` appear in the catalog without manual registration. Since the change, no service from those repositories is in the catalog. The teams from `starfleet-org` are the only entities that arrive, through a static location.

The environment is a kind cluster, not the Backstage application. The descriptor repositories are ConfigMaps named `repo-<name>` in the namespace `catalog-source`, and their annotations carry the repository facts (topics, visibility, default branch and organization). The catalog configuration is the ConfigMap `catalog-config` with the key `app-config.yaml`. The pod `deploy/catalog-tools` in `catalog-tools` runs `node /opt/check/inspect.js`, which models the catalog backend and prints a JSON report.

Repair the provider so that it meets all of these requirements:

1. The provider keeps its id `starfleetServices` and its organization `starfleet`. Do not add static locations for the services.
2. The provider builds at least three locations, and every one of them is found. Every repository keeps its descriptor in a file named `catalog-info.yaml` on the branch `main`.
3. The Components `scout` and `shuttle` (public repositories) are ingested through the provider.
4. Repositories with the topic `experiment` are not discovered, so the Component `probe` is not ingested.
5. Public and internal repositories are discovered, so the Component `bridge` is ingested. Private repositories are never discovered, so the Component `vault` is not ingested.
6. The provider does not run more often than every 10 minutes. The schedule has a `frequency` written as an object, and a `timeout`.
7. Do not change or delete any `repo-*` ConfigMap. The Components `hangar-legacy` (default branch `master`) and `outpost-relay` (organization `outpost-labs`) stay out of the catalog.

Check your work with `astrona submit`.
