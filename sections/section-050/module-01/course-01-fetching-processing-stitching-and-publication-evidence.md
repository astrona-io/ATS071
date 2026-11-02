---
draft: true
exam_objectives:
- Troubleshooting entity ingestion
---
# Fetching, Processing, Stitching And Publication Evidence

The catalog ingestion pipeline converts discovered data into entities that users can query. Its work includes receiving inputs from locations or providers, reading source data, parsing and validating entities, applying processors and assembling relationships for publication. These stages create several distinct places where a failure can occur. Good troubleshooting preserves that distinction rather than treating an absent entity as one generic catalog error.

Source discovery establishes what should be read. A manually registered location, static configuration or entity provider can supply the input. Fetching then needs a correct target and an authorized integration. A missing file, wrong branch, denied repository or unavailable source can all prevent this stage. The relevant evidence identifies the backend's request and authority, not only what a browser user can access.

Parsing and validation interpret the fetched document. Valid YAML can still have a malformed envelope, unsupported name or incorrect kind-specific specification. Catalog policies may reject a kind that the framework otherwise supports. The distinction matters because repairing source credentials will not make invalid entity data acceptable. Likewise, renaming a field will not repair a denied source request.

Processors can enrich entities, read additional locations and emit relationships. Their behavior should be deterministic enough for repeated ingestion to remain coherent. A processor that fails on one entity can prevent that entity from progressing even while other entities continue. Error handling should retain useful context, including the entity reference and processing step, without leaking source tokens or sensitive content.

Relationship assembly, often described as stitching, combines entity information and emitted relationships into the final representation. A Component can publish while its owner reference points to an entity that has not been ingested. The metadata pipeline may therefore be healthy in one sense while the user-visible relationship is incomplete. Investigating both endpoints of the relationship is more useful than assuming that the Component's source must be unreadable.

Consider an entity that appeared yesterday but no longer receives updates. First determine whether its source remains discoverable. Then examine fetch results, parsing errors and processor outcomes. If a recent descriptor change introduced an unsupported field shape, the source may be fetched successfully while publication stops progressing. That timing connects the metadata change to the failing contract without implying a runtime service outage.

Identity conflicts require source ownership analysis. Providers manage sets of entities associated with their own identity. Two providers should not claim the same canonical entity independently. Manual registration can also create overlapping discovery paths. Simply changing a display title does not resolve the conflict because the canonical kind, namespace and name remain the identity the catalog uses.

Processing errors can be exposed in the interface through appropriate error components and recorded in server evidence. The presence of a panel depends on application composition, so an empty entity page does not prove there are no server errors. Diagnose from both published metadata and ingestion evidence. A user-visible error should communicate the catalog failure rather than suggesting that the represented software necessarily crashed.

The durable repair belongs at the source of truth or the processor that owns the transformation. Editing a transient published record can be overwritten by the next cycle. Retrying can be appropriate for a temporary source failure, but repeated retries cannot repair a malformed envelope. Keeping those distinctions clear avoids turning diagnosis into an endless series of registrations and deletions.

## Common pitfalls

> [!WARNING]
> Do not infer a service outage from a catalog processing failure. Separate discovery, fetching, entity policy, processing and relationships. Repair authoritative inputs and ownership conflicts rather than editing transient published results that ingestion will replace.
