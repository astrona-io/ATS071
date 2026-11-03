---
draft: true
exam_objectives:
- Populate Backstage Catalog
---
# Descriptors, Entity Policies And Catalog Population

A Backstage catalog is empty until someone gives it descriptors and tells it where to find them. This module explains how a descriptor file becomes an entity, why the catalog sometimes refuses a file that looks correct, and how to find the cause. You work in a playground that holds a small catalog source, so every rule you read about can be tested on real files.

## Why this module matters

Most catalog problems that engineers report are population problems. An entity is missing, an owner cannot be opened, or a new repository never shows up. The cause is almost never an outage. It is a descriptor that breaks a format rule, a required field that is missing, a kind that the rules do not allow, or a repository that no location points at.

The module separates these causes into steps. Each step has its own evidence in the report that the playground produces. When you can name the step that failed, you can fix the right file instead of guessing.

## What you will learn

The module has three teaching chapters and a summary.

The first chapter covers the descriptor envelope: `apiVersion`, `kind`, `metadata` and `spec`. It explains the format rules for names, namespaces, labels, annotations and tags, and it shows which part of the catalog model enforces them. These checks are the entity policies.

The second chapter covers kinds and their required fields. It explains why a Component needs a lifecycle and a Group needs `children`. It also explains multi-document files, where one file declares several entities and each document is checked on its own.

The third chapter covers `catalog.rules` and the registration of locations. It explains the default list of allowed kinds, what happens when you replace it, rules that belong to one location, and the different ways to register a location.

## Learning goals

- Interpret the envelope and the specification of a catalog descriptor.
- Apply the name, namespace, label, annotation and tag rules to a descriptor.
- Name the required `spec` fields of the main kinds.
- Read a file with several documents and tell which documents were accepted.
- Explain location registration and processing as separate steps.
- Distinguish accepted entity kinds from valid YAML syntax.
- Change `catalog.rules` and a location rule without removing kinds that are needed.

## Before you start

You need a terminal with `kubectl` and `jq`, and the playground running. You do not need to know Backstage internals. You need to be able to read YAML and edit a text file.

You should know that an entity is one record of the catalog, such as a service, an API or a team. You should also know that a descriptor is a YAML file, usually named `catalog-info.yaml`, that lives in the repository of the software it describes. The chapters define every other term when it first appears.

## What the playground is

The playground is a kind cluster. Kind runs a small Kubernetes cluster inside a container. It does not run the Backstage application. The descriptor files are ConfigMaps in the namespace `catalog-source`, and each ConfigMap named `repo-<name>` stands for one repository. A ConfigMap named `catalog-config` holds the `catalog` section of an application configuration file.

A pod in the namespace `catalog-tools` reads those ConfigMaps and prints a JSON report. The pod validates every document with the real `@backstage/catalog-model` library, the same library that the catalog backend uses. It then models locations, rules and relations. It is a model of the catalog backend and not the backend itself, so it shows what the backend would decide about your files but does not store entities in a database.

You query the report with a shell helper function called `inspect_catalog`. The first hands-on step of each chapter shows it. You edit a descriptor by saving the file text on your machine, changing it and writing it back into the ConfigMap.

## What is in the playground

- A repository `starfleet-org` with an organization file that holds two Groups and a User.
- A repository `bridge` with a System and a Component in one file.
- A repository `scout` with one valid Component.
- A repository `probe` with three Components, two of them invalid.
- A repository `shuttle` that no location points at.
- A catalog configuration with four static locations and one rule that belongs to the organization location.

The playground is not graded. After the second chapter, a graded lab asks you to repair a larger set of faulty descriptors. A capstone lab at the end combines the rules, the locations and the descriptors.

## How to read the report

The report has a few lists that you will query often. The list `entities` has one item per document that the catalog read, with the fields `declared`, `valid`, `allowed` and `ingested`. The list `errors` has one item per problem, with a `stage` that tells you which check failed. The list `locations` shows each location with a status. The list `unresolved` shows references that point at entities the catalog did not accept.

The stages are `parse`, `policy`, `kind`, `rules` and `relations`. A stage is a step of processing. Reading the stage first saves time, because it tells you whether the problem is in the YAML text, in a format, in the `spec`, in the rules or in a reference.

An entity is ingested only when it is valid, allowed by the rules, free of malformed references and not in conflict with another entity of the same reference.

## How the chapters build on each other

The chapters follow the order in which a document is checked. A document is first parsed, then checked by entity policies, then by the kind validator, then by the rules. That is also the order in which you should read an error list: fix the earliest stage first.

Locations come before all of this, because a file that no location points at is never read. The third chapter therefore ends the module by connecting the steps into the full path from a repository to an accepted entity.

## What this module does not cover

The module does not cover annotations in detail, the troubleshooting of ingestion at scale, or automated discovery of repositories. It also does not cover how to host or secure the source repositories. It does not teach you to deploy software, because a descriptor describes software and does not run it.

## Key terms

- Descriptor: a YAML file that declares one or more entities.
- Entity: one record in the catalog, identified by its kind, namespace and name.
- Envelope: the outer fields `apiVersion`, `kind`, `metadata` and `spec`.
- Entity policy: a check of the envelope and of the field formats.
- Kind validator: a check of the `spec` fields that one kind requires.
- Location: a pointer to a descriptor file, with a `type` and a `target`.
- Catalog rule: a list of kinds that the catalog accepts, in total or for one location.
- Ingested: accepted by every check and stored as an entity.

## How long it takes

Each chapter takes about fifteen minutes with the playground. Plan another twenty minutes for the lab. Take a break between the chapters if a query does not return what you expect, and read the stage of the error before you change a file.

<!-- astrona:playground -->
