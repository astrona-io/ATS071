---
draft: true
exam_objectives:
- Understand how/why to use Backstage Catalog
---
# Describing And Finding Software

This module teaches how an engineer describes software so that other people can find it, judge it and trust it. You will read the fields `type`, `lifecycle`, `owner` and `tags`, filter the catalog by them and audit the catalog for stale or incomplete data.

The catalog is only useful when a person can answer a question such as "which production services does this team own" or "what depends on the software that is being retired". The answer depends on a few fields that every component must carry. This module shows what each field means, what the catalog checks and what it leaves to the author.

## Learning Goals

- Describe a component with `type`, `lifecycle`, `owner` and `tags`.
- Filter the entities of the catalog by those fields.
- Find software that is deprecated and the software that depends on it.
- Audit the catalog for missing owners, descriptions and tags.

## Learning Objectives

After this module you can:

- State which fields of a component are required and which values are common.
- Explain why `lifecycle` and `type` accept any string and what that costs.
- Write a filter that selects entities by kind, owner, lifecycle or tag.
- Use `dependsOn` relations to find who is affected by a deprecation.
- List entities that have an owner that does not exist.

## What the module covers

The first reading covers `type` and `lifecycle`. The second reading shows how to filter the catalog. The third reading follows a deprecation through the `dependsOn` relations. The fourth reading audits the quality of the catalog data. A graded lab follows the fourth reading, and a short summary closes the module.

## The playground

A playground is a clean environment with no task and no grading. This one is a kind cluster, a small Kubernetes cluster that runs in containers on your computer. It does not run Backstage. The descriptor files are ConfigMaps in the namespace `catalog-source`, and a checker pod in `catalog-tools` validates them with the real `@backstage/catalog-model` library and prints a JSON report.

The estate has the system `navigation`, the components `bridge`, `scout`, `shuttle` and `probe`, the API `bridge-api`, the resource `telemetry-db`, two groups and one user. The helper that prints the report is the same on every page:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

You need `kubectl` and `jq` on your computer and a container engine that kind can use. The labs and the playground are built from static checks only and are untested on a real cluster.

<!-- astrona:playground -->
