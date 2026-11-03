---
draft: true
exam_objectives:
- Using annotations
---
# Using annotations

This section covers annotations on catalog entities. An annotation is a named string in `metadata.annotations` that a plugin or processor reads to reach an external object: a repository, a documentation source, a Kubernetes workload or a link. The section explains how annotations differ from labels, tags and spec fields, which well-known keys exist, which keys the catalog writes itself, and why an annotation is metadata and never a permission.

The module has three lessons and a summary, a playground, a graded lab and a capstone lab. The environment is a kind cluster. It does not run Backstage. The descriptor files are ConfigMaps, and a pod runs a checker that validates them with the real `@backstage/catalog-model` library and models locations, rules and relations.

## Learning Outcomes

- Distinguish annotations from labels, tags and core specification fields.
- Explain how a plugin interprets an annotation value and which component does the work.
- Name the common well-known annotation keys and the value format of each.
- Explain why authors do not write the annotations that the catalog adds.
- Diagnose incorrect integration mappings without treating metadata as permission.
- Repair invalid label values, non-string values, invalid keys and copied identities.

## The Learning Path

### 1. Annotation Contracts And External Identity Mapping
*   **Module Reader:** the landing page and three lessons, then the summary.
*   **Hands-on Playground:** `sections/section-030/module-01/playground` - Starfleet descriptors with annotations to read, add and break.
*   **Module Lab:** `sections/section-030/module-01/labs/lab-01` - repair annotations on three Components.

### Capstone
*   **Capstone Lab:** `sections/section-030/capstone/labs/lab-01` - repair annotations across four repositories, including a key format, a secret and a misplaced spec field.
*   **Knowledge Check:** `sections/section-030/quiz.yaml`

The labs and playgrounds are UNTESTED: they were built and checked statically only (`astrona validate`, `bash -n`, YAML parsing and a local run of the checker). Nobody has run them on a cluster yet.
