# Question

Solve this question on: `terminal`

The shipyard estate has three descriptor repositories: `yard-org` (the teams `yard-ops` and `berth-team`), `gate` (the `gate` service) and `berth` (the `berth-board` website). Only the two Components and the two Groups are in the catalog. Nothing describes the shipyard as a whole, the API of the gate, or the database it uses, and `berth-board` consumes an API that does not exist as an entity.

Model the estate in the `gate` and `berth` repositories so that the catalog shows it completely:

1. Create a Domain `logistics` owned by `yard-ops`.
2. Create a System `shipyard` owned by `yard-ops` that belongs to the Domain `logistics`.
3. Create an API `gate-api` (type `openapi`, lifecycle `production`, owner `yard-ops`) in the System `shipyard`. Any valid OpenAPI definition text is accepted.
4. Create a Resource `dock-db` (type `database`, owner `yard-ops`) in the System `shipyard`.
5. The Component `gate` must belong to `shipyard`, provide `gate-api` and depend on `dock-db`.
6. The Component `berth-board` must belong to `shipyard` and consume `gate-api`.
7. The report must show zero errors and no unresolved relations.

Keep the existing owners, the Groups and the three repositories. The catalog configuration already allows every kind that you need, and it already reads one descriptor file from each repository.

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

`kubectl` already points at the cluster as the cluster administrator.
