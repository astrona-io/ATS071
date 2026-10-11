---
draft: true
exam_objectives:
- Using annotations
---
# Annotation Contracts And External Identity Mapping

Annotations attach named metadata to a catalog entity. They are commonly used to connect the entity to documentation, source systems or plugin-specific external resources. The annotation key identifies the contract, and its string value carries the identifier or other data expected by that contract. Meaning comes from the installed plugin or processor that consumes the key, not from YAML syntax alone.

Annotations differ from labels and core specification fields. Labels support relatively small classification values and filtering. Kind-specific fields such as a Component's owner describe the core entity model. An annotation can carry a plugin-specific locator that does not belong in that model. Choosing the right place for information keeps catalog behavior understandable and avoids inventing unsupported specification fields.

Consider a build-status card associated with a Component. The card may expect an annotation naming a particular external project. The backend integration uses that identifier to request the project's information. The correct value is therefore the external identity expected by the plugin, not the Component's display title unless the contract explicitly says they coincide. Two systems can name the same service differently.

A successful response does not prove that the mapping is correct. If the annotation points at another team's build project, the integration can return perfectly valid status for the wrong software. This is a semantic identity failure. Useful review checks the entity reference, annotation key, value format and external target together rather than looking only for network errors.

Some annotations are supplied or normalized during ingestion. For example, source-location information can help processors and integrations understand where an entity originated. A manually authored value can interact with derived metadata, depending on the consumer. Authors should identify whether a key is intended for direct authoring, processing output or a particular plugin. Copying every annotation from another entity can carry an unrelated external identity into the new record.

Annotations do not supply authorization. The backend still needs an approved credential and permission to read or act on the external target. A user seeing a project identifier in the catalog does not gain access to that project. Similarly, putting a token into an annotation would expose it as catalog metadata rather than creating a safe authentication mechanism.

Key naming helps avoid collisions. Widely used contracts often have domain-qualified names so independent plugins can distinguish their metadata. Organization-specific annotations should also use clear namespaces and documented semantics. Reusing a known key with a different meaning makes installed consumers behave unpredictably because they still interpret the original contract.

Change management needs to follow the consumer. A plugin upgrade can introduce a new accepted format or deprecate an older mapping. The annotation should be reviewed against the version of that plugin installed in the application. Schema validation may accept a string even when the plugin cannot interpret its content. This is another reason to distinguish envelope validity from integration correctness.

A practical diagnostic sequence begins with the entity actually shown in the interface. Confirm that it is the expected kind, namespace and name. Then inspect the annotation consumed by the card, identify the external object it names and determine whether the server identity may access that object. This follows the entire metadata join without assuming that a blank card always means a broken catalog.

## Common pitfalls

> [!WARNING]
> An annotation is metadata, not a secret store or permission grant. A valid string can identify the wrong external object. Avoid copied identifiers, unsupported keys and assumptions that the catalog's display name matches an integration's canonical identity.
