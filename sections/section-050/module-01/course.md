---
draft: true
exam_objectives:
- Troubleshooting entity ingestion
---
# Fetching, Processing, Stitching And Publication Evidence

This module teaches one skill: finding out why an entity is missing from the catalog, or is published with a broken relation, and repairing the real cause. You will learn the steps that turn a file in a source repository into a published entity. You will also learn which kind of evidence each step leaves behind.

The module is practical. You work in a playground where an inspector reports on a small estate of descriptor files, and you break and repair that estate yourself.

## Learning Goals

- Trace the catalog ingestion stages and their distinct outputs.
- Locate malformed data, source access and identity conflicts.
- Explain processing errors without confusing them with service outages.

## Learning Objectives

After this module you can:

- Name the steps of ingestion: fetch, parse, validate, check the rules, emit relations, stitch and publish.
- Say which component does the work in each step.
- Tell a fetch failure from a parse failure by the status of the location.
- Read a policy error and a kind error and find the field that breaks the rule.
- Explain why a valid entity can still be refused by the catalog rules.
- Find an unresolved relation and a conflict, which are not in the error list.
- Explain why a processing error is not evidence of a service outage.
- Repair a fault at the source of truth, not in the published result.

## Before You Start

You need to know what an entity is: a descriptor with an `apiVersion`, a `kind`, a `metadata` section and a `spec` section, written in YAML (YAML Ain't Markup Language). You need to know that Backstage is a developer portal and that its catalog stores entities such as `Component`, `API`, `Resource`, `Group` and `User`. A reference such as `component:default/bridge` names the kind, the namespace and the name of one entity.

You do not need to know how to run Backstage. Nothing in this module starts it.

## What the Playground Is

The playground is a single-node Kubernetes cluster created with kind. It is not the Backstage application and it does not run the Backstage catalog backend. It holds a model of the backend that is accurate where this module needs it and simple elsewhere.

The environment has two namespaces:

- The namespace `catalog-source` holds the descriptor files. Each ConfigMap named `repo-<name>` stands for one source repository, and each data key is a file name. The ConfigMap `catalog-config` holds the `catalog:` section of a Backstage configuration, with the catalog rules and the static locations.
- The namespace `catalog-tools` runs a pod with an inspector script. The inspector reads all the ConfigMaps and prints one JSON report. It validates each entity with the real `@backstage/catalog-model` library, the same library that the Backstage catalog uses for entity policies and kind schemas.

The inspector models the following: reading locations, parsing YAML documents, entity validation, the catalog rules, the relations that the built-in kinds produce, and identity conflicts. It does not model plugins, credentials, scheduling or the database.

## The Estate in the Playground

The playground starts with a working estate and one fault:

- `starfleet-org` declares two groups.
- `bridge` declares a Component that depends on a Resource.
- `scout` declares a Component for a website.
- `probe` declares a Component with a missing required field.

Every command in the module is a `kubectl` command or a `jq` filter on the report. You edit descriptors by saving a ConfigMap as a file and applying it.

## What You Will Do

The reading has three lessons and a summary. Each lesson has a hands-on section in the playground. A lab follows the last lesson, and a capstone lab closes the section.

1. The steps from a file to a published entity, and where each failure leaves evidence.
2. Fetch failures and parse failures: the location status, the branch and path of a target, and YAML mistakes.
3. Validation, catalog rules, relations and identity conflicts, and what stitching adds.

## How to Use the Inspector

The playground guide gives a shell function named `inspect_catalog`. The function sends the ConfigMaps to the pod and filters the report with `jq`. The same function appears in the labs.

The report has these parts:

- `.locations` has one item for each location that was read, with its status.
- `.entities` has one item for each YAML document that parsed, with the fields `valid`, `allowed`, `errors`, `relations` and `ingested`.
- `.errors` has one item for each error, with its stage.
- `.conflicts` lists references that two locations declare.
- `.unresolved` lists relations whose target is not ingested.
- `.summary` lists the ingested references and the number of errors.

## Habits to Build

Work from the order of the steps. Ask whether the location was read, whether the file parsed, whether the entity is valid and allowed, whether its relations resolve and whether another location claims the same reference.

Read the whole message of an error before you change anything. The message usually names the field or the rule.

Repair the source, which is the descriptor file or the configuration. Never repair the published result.

Make one change at a time and print the report after each change. This shows which change fixed which fault, and it shows when a change breaks something else.

## Honest Limits

The inspector is a model of the catalog backend. The messages in the real backend are worded differently, and the real backend shows errors in the interface and in its logs in ways that the model does not copy. The ideas carry over: the steps, their order and the kind of evidence each step produces.

The labs in this module are untested until a maintainer has run them.

<!-- astrona:playground -->
