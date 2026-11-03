---
draft: true
exam_objectives:
- Populate Backstage Catalog
---
# Populate Backstage Catalog

Every entity in a Backstage catalog starts as a descriptor, a YAML file in a repository. This section explains what a descriptor must contain, which checks the catalog applies before it accepts an entity, how `catalog.rules` and locations decide what is read and allowed, and how to repair files that the catalog refuses. You practice on a model of the catalog backend that runs in a kind cluster. It validates descriptors with the real `@backstage/catalog-model` library but does not run Backstage.

**Exam objective covered:** Populate Backstage Catalog (Backstage Catalog, CBA)

---

## What You Will Master

- Interpret the envelope and the specification of a catalog descriptor.
- Apply the format rules for names, namespaces, labels, annotations and tags.
- Name the required fields of the main entity kinds and write a multi-document file.
- Explain location registration and processing as separate steps.
- Distinguish valid YAML, valid entities and kinds that the catalog rules allow.
- Fix `catalog.rules` and register a location without opening the catalog too far.

---

## The Learning Path

### 1. Descriptors, Entity Policies And Catalog Population
*   **Module Reader:** **[Module 1: Descriptors, Entity Policies And Catalog Population](./module-01/course.md)**
*   **Hands-on Playground:** `sections/section-020/module-01/playground` - a kind cluster with descriptor repositories as ConfigMaps, one file with invalid documents and one repository that no location points at.
*   **Module Lab:** `sections/section-020/module-01/labs/lab-01` - find and fix six faults in five descriptor files.

### Capstone
*   **Capstone Lab:** `sections/section-020/capstone/labs/lab-01` - fix restrictive rules, register a location, follow a `Location` entity and repair the descriptors behind it.
*   **Knowledge Check:** `sections/section-020/quiz.yaml`

The labs and playgrounds are UNTESTED: they were built and checked statically only.
