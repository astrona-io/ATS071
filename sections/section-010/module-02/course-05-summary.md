---
draft: true
exam_objectives:
- Understand how/why to use Backstage Catalog
---
# Summary

A component describes itself with its type, its lifecycle, its owner and its tags. The type and the lifecycle are required, and the catalog checks that they exist, not what they say. A lifecycle such as `prod` is valid and breaks every filter that looks for `production`, so teams agree on the three common values: `experimental`, `production` and `deprecated`.

Filters read fields. The kind, type and lifecycle filters read `kind`, `spec.type` and `spec.lifecycle`. The owner filter reads the `ownedBy` relation, so it matches every spelling of the owner. The tag filter reads `metadata.tags`. An entity with a missing field never appears in a filter on that field.

Marking software as deprecated is a signal for people. It does not stop dependencies and it does not remove the entity. The dependents of a component are the components whose `dependsOn` names it. Removing a registration without a check leaves unresolved relations in the components that still depend on it.

An audit with a few queries finds the weak entries: unresolved relations, missing descriptions and missing tags. The catalog accepts all of them without an error, so the audit has to be done on purpose and repeated.

Key facts to remember:

- Type and lifecycle are required, and any string is valid.
- The owner filter reads a relation, not the text of the field.
- Deprecated is a signal, not a block.
- Search the dependents before you remove software.

<!-- astrona:playground:destroy -->
