---
draft: true
exam_objectives:
- Understand how/why to use Backstage Catalog
---
# Software Entities, Ownership And Discoverable Relationships

The Backstage software catalog stores a description of software and of the teams that own it. Each described thing is an entity, and entities point at each other through relations. This module explains what an entity is, how ownership and relations are written, and what keeps catalog data trustworthy. You work in a playground that models the catalog backend, so every claim here can be checked in a report.

## Learning goals

- Explain the catalog as a model of software and organizational relationships.
- Name the entity kinds and write an entity reference as `kind:namespace/name`.
- Declare an owner and read the relations that Backstage derives from the spec.
- Find unresolved references and fix them.
- Reason about the source of truth, freshness and how to judge whether the catalog is useful.

## What you will do

The playground holds three small descriptor repositories for a Starfleet estate: an organization file with two Groups, the `bridge` service with its API, System and database, and the `scout` website. You print a report from a checker pod and read entities, references and relations from it. Then you break a reference on purpose and see where the report shows the damage.

The environment is a kind cluster. It does not run the Backstage application. A pod uses the same `@backstage/catalog-model` library that the catalog backend uses to validate descriptors, and it models locations, rules and relations. The descriptor repositories are ConfigMaps, so the report is a model of what the catalog backend would ingest.

## Before you start

You need `kubectl`, `jq` and the `astrona` command. You do not need to know Backstage. The first page defines every term it uses.

## Reading order

1. Entities, kinds and entity references: what an entity is and how it is named.
2. Ownership and relations: how `owner`, `system`, `providesApis`, `consumesApis` and `dependsOn` become relations, and what unresolved means.
3. Source of truth, freshness and adoption: who owns each piece of data, how data goes stale and how to judge value.
4. Systems, domains, APIs and resources: how systems and domains group software and how API and dependency fields connect components.
5. Summary.

<!-- astrona:playground -->
