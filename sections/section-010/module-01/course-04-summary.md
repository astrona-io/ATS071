---
draft: true
exam_objectives:
- Understand how/why to use Backstage Catalog
---
# Summary

The Backstage software catalog is a model of software and of the organization that owns it. Everything in it is an entity with a kind, a namespace and a name. The reference `component:default/bridge` identifies one entity. A browser title, a repository name or a Pod name does not.

The kinds describe different things. A Component is a unit of software, an API is an interface, a Resource is infrastructure that a component uses, a System groups components, APIs and resources, and a Domain groups systems. Group and User describe the organization. Location points at more descriptor files.

Ownership and relations make the catalog useful. The `owner` field names a Group or User. The `system`, `providesApis`, `consumesApis` and `dependsOn` fields are turned into relations such as `ownedBy`, `partOf`, `providesApi`, `consumesApi` and `dependsOn`. A relation is only useful when its target is in the catalog. A reference to an entity that does not exist is unresolved and leads nowhere.

A catalog is only as good as its data. Each descriptor lives with the code it describes and changes in the same review. Two sources must not create the same entity. Valid data can still be old, so teams keep it fresh as part of normal work. Value is judged by tasks such as finding the owner of a service during an incident, not by counting entities.

The catalog describes software. It does not prove that a deployment is healthy, and it does not replace the systems that own deployment, infrastructure or identity data.

<!-- astrona:playground:destroy -->
