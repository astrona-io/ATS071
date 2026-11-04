---
draft: true
exam_objectives:
- Working with manually registered entity locations
---
# Working with manually registered entity locations

This section covers working with manually registered entity locations. A location is the address of a file that holds entity descriptors. The section shows how a person registers one by hand, how the catalog backend fetches and processes the file, how a `Location` entity and the rules shape what enters the catalog, and how a published entity lives, becomes orphaned or is retired.

The reading pages, the playground and the labs use a model of the catalog backend. A kind cluster holds the descriptor files as ConfigMaps, and a checker validates them with the real `@backstage/catalog-model` library. The Backstage application is not run.

## Learning Outcomes

- Explain a manually registered location as an ingestion input.
- Distinguish location removal from entity lifecycle and rediscovery.
- Diagnose registration, fetch and processing failures separately.
- Register a location in the static configuration and read its status.
- Resolve the targets of a `Location` entity and choose between a rule on one location and the global rules.
- Retire software at its source and find duplicate declarations of one entity.
- Explain the import flow, the pull request path and the free choice of descriptor file names

## The Learning Path

### 1. Registered Locations, Source Access And Entity Lifecycle
*   **Module Reader:** `module-01/course.md`, with four deep-dive readings and a summary.
*   **Hands-on Playground:** `sections/section-040/module-01/playground` - a kind cluster with a Starfleet estate that has static locations, a `Location` entity, a per-location rule and a retired repository.
*   **Module Lab:** `sections/section-040/module-01/labs/lab-01` - fix a wrong branch, a blocked kind, a mistyped target and a retired registration.

### Capstone
*   **Capstone Lab:** `sections/section-040/capstone/labs/lab-01` - register a root `Location`, repair the global rules, remove a duplicate declaration and retire a component.
*   **Knowledge Check:** `sections/section-040/quiz.yaml`

The labs and playgrounds are UNTESTED: they were built and checked statically only.
