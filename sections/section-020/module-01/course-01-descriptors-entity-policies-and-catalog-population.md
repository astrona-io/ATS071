---
draft: true
exam_objectives:
- Populate Backstage Catalog
---
# Descriptors, Entity Policies And Catalog Population

Catalog population begins with entity data and a discoverable source. A descriptor commonly uses YAML with an envelope containing apiVersion, kind and metadata, followed by a kind-specific spec. The envelope tells the catalog how to interpret the entity and establishes its name, namespace and descriptive metadata. The specification defines properties such as component type, lifecycle and ownership for the selected kind.

A descriptor is a declaration about software, not an instruction to deploy it. A Component description can identify a service and its owner while leaving the service runtime entirely unchanged. This boundary prevents a common misunderstanding: adding a database Resource to the catalog does not provision a database. Another platform API or workflow must perform that operation if it is required.

The source must then enter ingestion. Static configuration can identify locations, a user can register a supported location, or an automated provider can discover entities. The catalog reads the supplied data, validates it through configured policies and processes relationships. Publication makes the resulting entity available through catalog APIs and the interface. Registration and publication are therefore different observations.

For example, an author can register a repository containing a Component descriptor whose owner references an expected group. Fetching may succeed while a policy rejects the descriptor's shape. Publication may succeed while the referenced owner is missing from organization ingestion. The useful diagnosis identifies which contract failed rather than treating every case as a source-host connectivity problem.

The entity envelope uses stable identifiers. Names and namespaces need to satisfy the catalog's rules, while kind determines the permitted specification. A display title can be descriptive without replacing the entity's canonical reference. Descriptions and labels support discovery, but integrations often rely on exact references and annotations. A seemingly cosmetic rename can therefore affect other features.

Catalog rules determine which kinds are accepted from a source. An application can deliberately restrict ingestion to particular kinds. A descriptor that is valid for its schema may still be refused by that policy. Configuration changes also need care because replacing a rules list can remove previously allowed kinds. YAML syntax, entity validity and application acceptance policy are three separate boundaries.

A source integration needs authorized reading access. A browser user being able to view a repository does not prove that the backend's integration identity can read it. Private sources, organization restrictions and branch paths can all matter. The descriptor should remain free of credentials; backend integration configuration supplies access through a controlled server path.

Population should preserve source ownership. A descriptor near a service can be maintained by its team, while user and group information can come from an authoritative directory. A processor can enrich or normalize data, but its transformations should be understood and repeatable. If two pipelines claim conflicting versions of the same entity, the catalog needs a deliberate ownership rule rather than accidental last-write behavior.

Relationship quality is as important as record count. A populated catalog with missing owners and misleading dependencies can make decisions harder. Review should therefore examine what was published, where it came from and whether references identify the intended entities. That evidence is stronger than a message saying that one location was registered successfully.

This fictional descriptor illustrates the Component envelope and required relationships; it is metadata rather than a deployment instruction:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ordering-service
  namespace: default
spec:
  type: service
  lifecycle: experimental
  owner: group:default/commerce
```

The kind determines specification meaning. The owner reference identifies a catalog group, which must have its own maintained source. Experimental is lifecycle metadata, not an access-control setting or proof that production resources are isolated.

## Common pitfalls

> [!WARNING]
> Registration success does not prove entity publication, and valid YAML does not prove policy acceptance. Keep credentials out of descriptors. Distinguish source access, entity validity, allowed kinds and relationship quality when investigating population failures.
