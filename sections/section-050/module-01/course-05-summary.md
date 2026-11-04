---
draft: true
exam_objectives:
- Troubleshooting entity ingestion
---
# Summary

Catalog ingestion turns files in source repositories into published entities. The work happens in the background, in steps, and every step leaves its own kind of evidence. The most useful habit in this module is to ask which step stopped, before asking what is wrong.

## The steps and who does the work

An entity provider or a registered location tells the catalog backend which sources to read. The reader of the integration for the source host fetches the file, using credentials that belong to the backend. The backend stores each entity in its unprocessed form.

The processors then handle each entity one at a time. They parse and validate it, apply the catalog rules, emit relations and, for a Location entity, emit more locations to read. The stitcher merges the processed entity with the relations that other entities emitted about it. The merged result is the final entity, and only the final entity is visible to the interface and the API.

Because the work is done in the background, a change to a descriptor does not show immediately. The catalog is eventually consistent: the result appears after the next cycle of the step that reads the source.

## Fetch failures

A fetch failure means that the backend could not get the file. The location has no entities, and the entity was never seen. The usual causes are a branch in the URL that does not hold the file, a wrong path or file name, a repository that the credentials of the backend cannot reach, and a location type that no reader supports.

The evidence is a location whose status is not ok and an error with the stage fetch. The descriptor is not the problem, so editing it cannot help. The repair is in the pointer or in the access of the backend.

Credentials belong to the backend. A user who can open a repository in a browser tells nothing about whether the backend can read it.

## Parse failures

A parse failure means that the file arrived but one of its documents is not valid YAML. The location status is ok, and the error has the stage parse with a line and a column. The error has no entity reference, because the kind and the name come from the text that did not parse.

The most common cause is a colon followed by a space inside an unquoted value. Quoting the value repairs it. Other causes are tabs used for indentation and wrong indentation in lists. A broken document does not have to hide the other documents of the same file.

## Validation failures

A valid YAML document can still fail validation. The entity policies check the envelope that every entity shares: the API version, the kind, the metadata, and the format of names, labels and annotation keys. A name may contain only letters, digits and the separators dash, underscore and dot, up to 63 characters. A label value follows a similar rule.

The schema of the kind checks the spec. A Component needs a type, a lifecycle and an owner. A Group needs a type and a children list, which may be empty. An API needs a type, a lifecycle, an owner and a definition. A Resource needs a type and an owner.

The evidence is an error with the stage policy or kind and a message that names the field. An invalid entity is not published. The documentation says that an entity with an error does not replace the last error-free version, so an old version can stay visible while a broken change is rejected.

## The catalog rules

A valid entity must also be allowed. The catalog rules list the kinds that the catalog accepts. Without a rules setting, the default allows Component, System, API, Resource and Location. It does not allow Group, User or Domain. A rules setting in the configuration replaces the default.

A rule inside a location applies only to entities that the backend read from that exact URL. Entities reached through a Location entity are checked against the global rules only.

The evidence is an error with the stage rules. The body of the entity is valid, so editing the descriptor cannot repair it. The repair is in the configuration, and the question to ask first is whether that kind should be allowed from that source at all.

## Relations and unresolved targets

A relation is derived from a field of the spec. The owner field gives ownedBy, the system field gives partOf, the providesApis field gives providesApi, and the dependsOn field gives dependsOn. Every relation has a reverse type that is stored on the target, which is why a group page can list what the group owns.

A reference to an entity in a field that accepts several kinds needs a kind. The text of a dependsOn entry must look like resource, namespace and name, not only a name. Without the kind the processing of the entity fails with a relations error.

A reference that is well formed but points at nothing does not fail. The entity is published and the relation stays open. The report lists it as unresolved, and there is no error. The target may be missing because its location was not found, its file did not parse, its kind was not allowed, or nobody wrote it. The right repair is always at the target.

## Identity conflicts

The identity of an entity is its kind, its namespace and its name. The catalog keeps one entity per reference. When a second location declares the same reference, one descriptor wins and the other does not become an entity. A copied descriptor with an unchanged name is the usual cause.

A conflict does not have to appear in the error list. It appears in a list of conflicts that names the reference and both locations. A reader who looks only at errors will miss it and will see only a missing entity.

Changing the title or the description does not resolve a conflict, because they are not part of the identity. The descriptor that is wrong must get its own name. Providers manage sets of entities, and two providers should not claim the same entity. A provider and a static location can overlap in the same way.

## Stitching and effects on other entities

A failure of one entity affects the entities around it. If a group is not ingested, every component that names it as owner has an open relation, and none of those components has an error. A page can therefore look incomplete while the descriptor of the page is fine.

For this reason, diagnose both ends of a relation. Look at the entity that points and at the entity that is pointed at.

## Not an outage

A processing error describes the metadata pipeline. It does not say that the described software is down. A service can run without a fault while its descriptor fails validation, and a descriptor can be perfect while the service is down.

In the same way, a missing entity page does not prove that the catalog backend is down. Check the steps in order, and look for a location that was not found, a document that did not parse, an entity that was refused or a conflict, before you suspect the backend.

An empty error panel on an entity page does not prove that there are no server errors. The panel depends on how the application is composed, so diagnose from both the published metadata and the ingestion evidence.

## Repair at the source

The durable repair belongs to the source of truth: the descriptor file, or the catalog configuration, or the processor that owns a transformation. A published entity is a result that the next cycle replaces, so an edit to the result does not last.

Retry helps only for a temporary failure, such as a source that was unreachable for a short time. A malformed file or a rule that refuses a kind fails the same way every time.

Deleting and registering a location again does not repair a wrong pointer. It repeats the same pointer. Change one thing at a time and read the evidence again, so that you know which change did what.

## Key facts

- The steps are fetch, parse, validate, rules, relations, stitching and publication.
- Each step leaves evidence in a different place: location status, parse errors, policy and kind errors, rules errors, the unresolved list and the conflicts list.
- A fetch failure is repaired in the location or in access. A parse failure is repaired in the file.
- A valid entity can be refused by the rules, and the repair is in the configuration.
- Unresolved relations and conflicts are not in the error list.
- A processing error is not a service outage.
- The repair belongs at the source of truth.


<!-- astrona:playground:destroy -->
