---
draft: true
exam_objectives:
- Using annotations
---
# Summary

An annotation is one entry in the `metadata.annotations` map of a catalog entity. The key names a contract and the value is a string. The catalog backend stores the pair and checks its format. It does not know what the value means. Meaning comes from the code that reads the key: a frontend plugin, a backend plugin or a processor.

That design has a direct consequence. The catalog does not verify that an annotation names a real object, and it does not verify that the object belongs to the entity that carries the annotation. A descriptor can hold a correct-looking project slug that names another team's repository, and every check passes. The page then shows real data about the wrong software. This is a semantic identity failure. It is found only by comparing the entity, the annotation key and the external object together.

Annotations do not grant access. When a user opens an entity page, the backend plugin calls the external system with its own configured credential. The annotation value only tells the plugin which object to ask about. A user who sees an identifier gains no access to the object. A password or token written into an annotation is not protected, because the annotation is part of the entity and anyone who can read the catalog can read it. Credentials belong in backend configuration.

The four places for extra information have different jobs. Labels classify and filter, and their values are short names. Tags are single-word classifiers. Spec fields define the kind, and the catalog reads them to validate the entity and to build relations. Annotations hold pointers to external systems, and any string is allowed. The question that decides the place is who reads the value.

The catalog applies strict rules at the policy stage. A label value that contains a locator, such as `dir:.`, is rejected. An annotation value that is not a string, such as an unquoted `true` or a number, is rejected. An annotation key with a space is rejected. In each case the whole entity is rejected, so one bad value removes a component from the catalog. A required spec field that was written as an annotation passes the policy stage and fails the kind validator.

Keys that are shared between tools carry a domain prefix. The prefix `backstage.io/` is reserved for Backstage. An organization that needs its own key uses its own domain and documents the value. Reusing a known key for a different meaning makes the installed plugin read the wrong data. A key that differs by one character is a different key, and nothing reads it.

The common well-known keys and their value formats are worth remembering.

- `backstage.io/techdocs-ref` names the documentation source, usually `dir:.`.
- `backstage.io/source-location` is a location reference to the source code, and a folder needs a trailing slash.
- `github.com/project-slug` is `<owner>/<repository>`, not a web address.
- `backstage.io/kubernetes-id` and `backstage.io/kubernetes-label-selector` tell the Kubernetes plugin which workloads belong to the entity.
- `backstage.io/view-url` and `backstage.io/edit-url` change the links on the entity page.

Two keys are written by the catalog and not by authors. `backstage.io/managed-by-location` records the location that the entity was read from. `backstage.io/managed-by-origin-location` records the location whose registration created the entity. The catalog uses them to know which entities to update or remove when a location changes. An author does not copy them into a descriptor.

A good review has three steps. Confirm that each key is a known contract and is spelled exactly. Confirm that each value has the format of the contract. Confirm that each value names this entity's object. Run these steps whenever a descriptor is created from a copy of another one, because copying carries external identities that belong to someone else.

Finally, schema validity is not integration correctness. A descriptor that passes every check in the catalog can still produce a blank or misleading card. When a card is empty, check the entity that is shown, the annotation that the card reads, the object that it names, and whether the backend credential can read that object. Do not assume that an empty card means a catalog failure, and do not assume that a full card means a correct mapping.

<!-- astrona:playground:destroy -->
