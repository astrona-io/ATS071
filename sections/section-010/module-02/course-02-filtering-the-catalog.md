---
draft: true
exam_objectives:
- Understand how/why to use Backstage Catalog
---
# Filtering The Catalog

The catalog interface lets a person filter the entity list by kind, owner, lifecycle, type and tag. Each filter selects entities whose fields have a given value. This part builds the same filters with `jq` on the report, so you see which field each filter reads.

## The fields behind the filters

The kind filter reads `kind`. The type and lifecycle filters read `spec.type` and `spec.lifecycle`. The owner filter reads the `ownedBy` relation, which comes from `spec.owner`. The tag filter reads `metadata.tags`. In the interface, a filter on a field that no entity has shows an empty list, not an error.

A filter is only as good as the data. An entity without tags never appears in a tag filter, and an entity with a lifecycle in a different spelling never appears in a lifecycle filter. This is why the previous reading matters.

<!-- astrona:playground:renew -->

Paste the helper function once:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

Select the components with the lifecycle `production`:

```sh
inspect_catalog -r '.entities[] | select(.kind == "Component" and .spec.lifecycle == "production") | .ref'
```

Select the entities that carry the tag `cargo`:

```sh
inspect_catalog -r '.entities[] | select((.metadata.tags // []) | index("cargo")) | .ref'
```

Select the entities owned by the group `starfleet-ops`. The owner filter uses the relation, so it also finds owners written as `group:default/starfleet-ops`:

```sh
inspect_catalog -r '.entities[] | select(any(.relations[]?; .type == "ownedBy" and .target == "group:default/starfleet-ops")) | .ref'
```

The result lists `bridge`, `bridge-api`, `telemetry-db`, `navigation` and `probe`. Reading the relation and not the raw text of the field is the reason that both spellings of the owner match.

## Combine filters

The interface combines filters with a logical "and". Select the production components of one owner:

```sh
inspect_catalog -r '.entities[] | select(.kind == "Component" and .spec.lifecycle == "production" and any(.relations[]?; .type == "ownedBy" and .target == "group:default/starfleet-ops")) | .ref'
```

Only `bridge` is in the result. `shuttle` is a production component too, but its owner is `scout-team`. Change the owner of `shuttle` to `starfleet-ops`, apply the file as the previous reading did and run the filter again. Two components are in the result now. Change the owner back.

## What you now know

You know which field each filter reads and why the owner filter reads a relation. The open question is what to do with the filter result when a piece of software is retired.

## Common pitfalls

> [!WARNING]
> An entity with no tags is invisible to a tag filter. An owner filter on the text of `spec.owner` misses owners written with a kind and a namespace. A filter that returns nothing does not prove that the software does not exist.
