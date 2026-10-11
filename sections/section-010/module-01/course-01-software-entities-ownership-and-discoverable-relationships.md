---
draft: true
exam_objectives:
- Understand how/why to use Backstage Catalog
---
# Software Entities, Ownership And Discoverable Relationships

The software catalog is a structured model of an organization's software and the relationships around it. Developers use it to find components, understand ownership, locate APIs and discover supporting resources. Its value comes from consistent identity and maintained relationships, rather than from presenting a long unstructured list of repository names.

Entities have kinds that express what they represent. A Component can represent a service, website or library. An API describes an interface. A Resource represents infrastructure needed by software, while a System can group related capabilities. Users and Groups describe organizational actors. The selected entity kinds and specifications determine which relationships the catalog can derive and present.

A fully qualified entity reference combines kind, namespace and name. This is more precise than a human-readable title. Two components can have similar display titles while differing by namespace or name. References should remain stable enough for integrations and relationships to find the intended entity. Renaming an entity can affect annotations, links and references even when its display card looks almost unchanged.

Consider a payment service that exposes an API and depends on a database. Its Component entity can identify the owner and system, while its relationships connect it to the API and Resource. The database Resource describes a dependency; it is not a live database connection. The owner relationship identifies the responsible group; it does not automatically grant that group permissions in every external system.

The catalog needs a source-of-truth strategy. Many organizations store descriptors near the software source so changes can be reviewed with code. Other metadata may come from authoritative organization directories or asset systems. Combining sources requires ownership rules to avoid contradictory identities. A manually registered entity and an automated provider should not independently claim the same entity without a deliberate resolution strategy.

Freshness affects usefulness. A catalog record can be syntactically valid but refer to a team that no longer exists or a service that was retired. Processing success tells authors that the data passed its ingestion contracts. It does not prove that the data remains operationally accurate. Owner review, lifecycle practices and appropriate automated signals can improve that accuracy.

The catalog enables integrations through metadata. A plugin can use an annotation to connect an entity to a build project or documentation location. This creates a join between catalog identity and an external system's identity. If that join is wrong, the card can display unrelated information even while every API call succeeds. The integration contract therefore needs exact interpretation and ownership.

Useful adoption starts with real discovery tasks. If developers need to find service owners during an incident, owner completeness and current contact paths matter more than the number of installed cards. If they need to understand API dependencies, relationship quality matters. Measuring whether those tasks become easier provides better feedback than counting catalog records alone.

The portal can combine catalog metadata with live information, but the distinction should remain visible. A deployment-status integration may show recent controller information alongside a Component description. That live status belongs to its external source and update path. Catalog presence alone should never be presented as proof that the running system is healthy.

## Common pitfalls

> [!WARNING]
> Do not confuse a catalog entity with a running workload or assume ownership metadata grants external permissions. Maintain stable references and clear source ownership. Valid ingestion is necessary for catalog operation but does not establish that every relationship is current and true.
