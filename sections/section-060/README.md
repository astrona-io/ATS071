---
draft: true
exam_objectives:
- Working with automated ingestion
---
# Working with automated ingestion

This section covers automated ingestion in the Backstage catalog. An entity provider finds descriptor files in a source system, such as the repositories of a GitHub organization, and hands them to the catalog on a schedule. The section explains what a provider and a processor each do, how GitHub discovery decides which repositories are in scope, how the schedule and the update mode affect freshness and removal, and what goes wrong when a provider and a static location describe the same entity.

The hands-on work runs in a kind cluster. It does not run Backstage. A pod runs a model of the catalog backend that validates every descriptor with the real `@backstage/catalog-model` library and applies locations, rules and GitHub discovery providers. The labs are UNTESTED: they were checked statically only and no maintainer has run them yet.

## Learning Outcomes

- Explain entity providers and processors as distinct ingestion roles.
- Read a GitHub discovery provider and predict which repositories it discovers.
- Reason about scheduling, full and incremental updates.
- Identify ownership, filtering and credential risks in automated discovery.
- Find and remove a duplicate between a provider and a static location.
- Choose providers per source, handle organization data and avoid overlapping sources

## Learning Path

| Step | Content | Path |
| --- | --- | --- |
| 1 | Landing page and four lessons | `module-01/course.md` and `module-01/course-0N-*.md` |
| 2 | Playground | `module-01/playground` (`ats-071-playground-060-01`) |
| 3 | Module lab: fix GitHub discovery filters | `module-01/labs/lab-01` (`ats-071-lab-060-01`) |
| 4 | Summary | `module-01/course-05-summary.md` |
| 5 | Capstone lab: finish a provider migration | `capstone/labs/lab-01` (`ats-071-capstone-060`) |
| 6 | Knowledge check | `quiz.yaml` |
