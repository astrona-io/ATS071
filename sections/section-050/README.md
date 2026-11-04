---
draft: true
exam_objectives:
- Troubleshooting entity ingestion
---
# Troubleshooting entity ingestion

This section covers troubleshooting entity ingestion in the Backstage catalog. Ingestion is the background work that turns files in source repositories into published entities. It has several steps, and a failure in each step looks different and needs a different repair. The section teaches you to read the evidence, place a failure in its step and repair it at the source.

The hands-on parts use a kind cluster. The descriptor files are ConfigMaps, and a pod runs an inspector that checks them with the real `@backstage/catalog-model` library and models locations, rules, relations and conflicts. It is a model of the catalog backend. It does not run Backstage.

## Learning Outcomes

- Trace the catalog ingestion stages and their distinct outputs.
- Locate malformed data, source access and identity conflicts.
- Explain processing errors without confusing them with service outages.
- Tell a fetch failure from a parse failure, a validation failure, a rules refusal, an unresolved relation and a conflict.
- Repair each fault in the descriptor or the configuration that causes it.
- Triage ingestion errors in the order of the processing stages

## The Learning Path

### 1. Fetching, Processing, Stitching And Publication Evidence
- **Module Reader:** module-01/course.md
- **Hands-on Playground:** `sections/section-050/module-01/playground` - a working estate with one faulty repository and the inspector.
- **Module Lab:** `sections/section-050/module-01/labs/lab-01` - find and fix five faults, one for each ingestion stage.

### Capstone
- **Capstone Lab:** `sections/section-050/capstone/labs/lab-01` - repair an estate with seven faults across rules, relative locations, validation, relations and an identity conflict.
- **Knowledge Check:** `sections/section-050/quiz.yaml`

The labs and playgrounds are UNTESTED: they were built and checked statically only (validation of the lab configuration, shell syntax, YAML parsing and a local run of the inspector). A maintainer has not run them on a cluster yet.
