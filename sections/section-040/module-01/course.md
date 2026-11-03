---
draft: true
exam_objectives:
- Working with manually registered entity locations
---
# Registered Locations, Source Access And Entity Lifecycle

This module teaches how a person tells the catalog where descriptor files
live, and what the catalog does with that information. You will register
locations, follow a `Location` entity from one file to many, read the errors
of each stage and retire software through its source.

A location is the address of a file that holds one or more entity
descriptors. The catalog backend fetches the file, validates each document,
applies the rules for allowed kinds and publishes the entities. Every one of
those steps can fail on its own. The module shows where each failure appears
and which component is responsible for it.

## Learning Goals

- Explain a manually registered location as an ingestion input.
- Distinguish location removal from entity lifecycle and rediscovery.
- Diagnose registration, fetch and processing failures separately.

## Learning Objectives

After this module you can:

- Name the two ways to register a location by hand, the static
  `catalog.locations` configuration and the catalog interface or API, and
  state who can remove each one.
- Write a location with the type `url` and a target, and explain why the
  backend integration needs access to the file, not the person.
- Read a `Location` entity and resolve its relative and absolute targets.
- Choose between a `rules` list on one location and the global
  `catalog.rules` key, and state what each one covers.
- Explain why deleting a published entity does not retire it while its
  source still produces it.
- Describe orphaned entities, the annotation `backstage.io/orphan` and the
  setting `catalog.orphanStrategy`.
- Find an entity reference that two files declare and decide which
  declaration to remove.

## What the module covers

The first reading follows a registration from the address to the fetch. It
compares the static configuration with the interface and the API, and it
shows a fetch error for a branch that does not exist.

The second reading covers the `Location` entity, its `target` and `targets`
fields, the way relative paths resolve, the rules that allow kinds, and what
removing a registration changes.

The third reading covers the life of a published entity: the parent that
maintains it, deletion that does not last, orphans, rediscovery and
conflicts between two declarations.

A short summary closes the module. After the first two readings there is a
graded lab, and a capstone lab follows the summary.

## The playground

A playground is a clean environment with no task and no grading. This one is
a kind cluster, which is a small Kubernetes cluster that runs in containers
on your computer. It does not run Backstage. It models the catalog backend
well enough to study the inputs that this module covers.

The namespace `catalog-source` holds the source. A ConfigMap named
`repo-<name>` is one repository, and each key of its data is a file. The
ConfigMap `catalog-config` holds the `catalog:` part of the application
configuration. A pod in the namespace `catalog-tools` runs a checker script.
The checker validates every document with the real `@backstage/catalog-model`
library and models locations, rules, relations and duplicate declarations.

The model has limits. It has no database, no processing schedule, no orphan
handling and no registration API. When a reading page describes those
parts, it says so, and the page does not ask you to run them.

## The Starfleet estate in the playground

The playground starts with a working estate:

- Four locations in `catalog.locations`: an organization file with its own
  `rules` list, a root file with a `Location` entity, the `bridge`
  repository and the retired `legacy-probe` repository.
- A `Location` entity that lists two files with relative targets.
- Two groups and a user, and the components `bridge`, `shuttle`,
  `cargo-hauler` and `probe`.
- A repository for `scout` that nothing registers yet.

You will break and repair this estate in small steps: change a branch,
mistype a target, remove a rule, retire a registration and declare one
entity twice.

## How to work through the pages

Read each page from the top. Each page has a few commands that you run in
the playground, and each page starts the playground timer again before the
first command. Run the commands in the order of the text, because each step
builds on the state of the step before.

The helper function that reads the report is the same on every page:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

It sends all ConfigMaps of `catalog-source` to the checker, and `jq` filters
the JSON report. The parts of the report you will read are `.locations`,
`.entities`, `.errors`, `.conflicts` and `.summary`.

## Labs and status

The labs follow the readings and grade the state of the catalog setup, not
the exact text of your files. A lab checks outcomes such as "the component
is ingested" and "no location fails to fetch". The labs and the playground
are built from static checks only and are untested on a real cluster until a
maintainer runs them.

## Before you start

You need `kubectl` and `jq` on your computer, and a container engine that
kind can use. Use short sessions: the playground has a timer, and every
reading page that needs it renews the timer before the first command.

The pages use a few terms again and again. A ConfigMap is a Kubernetes
object that stores named text values. A descriptor is a YAML file that
describes an entity. An entity reference has the form
`kind:namespace/name`, for example `component:default/bridge`. A processing
stage is one step of the work that the catalog backend does on a file.

<!-- astrona:playground -->
