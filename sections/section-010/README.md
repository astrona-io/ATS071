---
draft: true
exam_objectives:
- Understand how/why to use Backstage Catalog
---
# Section 010: Understand how/why to use Backstage Catalog

The Backstage software catalog describes software and the people who own it as entities that point at each other. This section explains entities, kinds and references, ownership and relations, and the data practices that keep a catalog useful.

**Exam objective covered:** Understand how/why to use Backstage Catalog (Certified Backstage Associate, CBA)

---

## What You Will Master

- Name the entity kinds and write entity references
- Declare owners and read the relations the catalog derives
- Find and fix unresolved references
- Explain source of truth, freshness and adoption
- Group software into systems and domains and connect components through APIs and dependencies

---

## The Learning Path

### 1. Software Entities, Ownership And Discoverable Relationships
*   **Module Reader:** **[Module 1](./module-01/course.md)**
*   **Hands-on Playground:** `sections/section-010/module-01/playground` - a kind cluster with a checker pod and a small Starfleet estate.
*   **Module Lab:** `sections/section-010/module-01/labs/lab-01` - make owners and relations resolve.

### 2. Describing And Finding Software
*   **Module Reader:** **[Module 2](./module-02/course.md)**
*   **Hands-on Playground:** `sections/section-010/module-02/playground` - a kind cluster with components of several lifecycles, types and tags.
*   **Module Lab:** `sections/section-010/module-02/labs/lab-01` - fix a lifecycle, a deprecation and an owner.

### Capstone
*   **Capstone Lab:** `sections/section-010/capstone/labs/lab-01` - model a small estate from scratch.
*   **Knowledge Check:** `sections/section-010/quiz.yaml`

The labs and playgrounds are UNTESTED: they were built and checked statically only. They model the catalog backend; they do not run Backstage.
