---
draft: true
exam_objectives:
- Understand how/why to use Backstage Catalog
---
# Auditing Catalog Quality

A catalog loses value when entries are incomplete or point at nothing. A short audit finds the weak entries with a few queries, so a team can fix them on a schedule. This part builds four queries for the common weak spots: unresolved references, missing descriptions, missing tags and owners that are people and not teams.

## What to look for

An unresolved relation means that a reference names an entity that does not exist, for example an owner group with a typing mistake. A missing description leaves a reader guessing what the software does. A missing tag hides the entity from tag filters. An owner of kind `User` ties the software to one person, who may leave. The catalog accepts all four cases without an error.

<!-- astrona:playground:renew -->

Paste the helper function once:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

List the unresolved relations:

```sh
inspect_catalog -c '.unresolved'
```

The list is empty in the starting estate. List the entities that have no description:

```sh
inspect_catalog -r '.entities[] | select(.ingested == true and (.metadata.description // "") == "") | .ref'
```

The groups `starfleet-ops` and `scout-team` have descriptions, and the user `kira`, the system `navigation`, the API `bridge-api` and the resource `telemetry-db` do not. List the components that have no tags:

```sh
inspect_catalog -r '.entities[] | select(.kind == "Component" and ((.metadata.tags // []) | length) == 0) | .ref'
```

`bridge` and `scout` are in the list. Add `tags: [routing]` to the `metadata` of `bridge`, apply the file and run the query again. Only `scout` remains.

## Make the audit one command

Combine the checks in one report with counts:

```sh
inspect_catalog -c '{unresolved: (.unresolved | length), noDescription: [.entities[] | select(.ingested == true and (.metadata.description // "") == "") | .ref] | length, componentsWithoutTags: [.entities[] | select(.kind == "Component" and ((.metadata.tags // []) | length) == 0) | .ref] | length}'
```

Run it on a schedule and watch the numbers fall. A growing number means that new entries enter the catalog without these fields.

## What you now know

You can find unresolved references, missing descriptions and missing tags with short queries, and you know why each gap lowers the value of the catalog. The wider habit is to treat the catalog as data that needs an owner and a review, not a one-time import.

## Common pitfalls

> [!WARNING]
> An empty list of unresolved relations does not mean that the data is complete. A missing description or tag raises no error. Do not fix an audit by deleting entities: fix the descriptor, so the next pass keeps the fix.
