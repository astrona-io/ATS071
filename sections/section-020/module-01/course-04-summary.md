---
draft: true
exam_objectives:
- Populate Backstage Catalog
---
# Summary

A catalog is populated from descriptors. A descriptor is a YAML file that declares one or more entities, and the catalog accepts an entity only after a series of checks. The checks run in a fixed order, and each failure leaves a different kind of evidence. Knowing the order is what lets you diagnose a missing entity quickly.

## The envelope and its formats

Every document has the same envelope: `apiVersion`, `kind`, `metadata` and, for most kinds, `spec`.

The `apiVersion` and the `kind` together decide which kind validator checks the document, so the `apiVersion` is part of the contract and not a free label.

The `metadata.name` field is required. It uses letters and digits separated by `-`, `_` or `.`, it has at most 63 characters, and it cannot contain a space.

The `metadata.namespace` field defaults to `default` and uses letters and digits separated by `-`.

Labels and annotations are maps of string keys to string values. Their keys have an optional lowercase prefix, a `/` and a name part.

Tags are short lowercase strings.

The title and the description help readers. They do not identify the entity, because identity comes from the kind, the namespace and the name.

An entity reference has the form `kind:namespace/name`, and the catalog compares its parts without regard to case.

## Entity policies

Entity policies are the first checks that a parsed document meets.

The schema policy requires `apiVersion`, `kind` and `metadata.name`.

The namespace policy fills in the default namespace.

The foreign root fields policy refuses any top-level field that the envelope does not define, so ownership written at the top level is an error.

The field format policy enforces the format rules of names, namespaces, labels, annotations and tags.

A document that fails a policy never reaches the kind validator.

## Kinds and required fields

Each built-in kind has a validator with required fields.

- Component: `type`, `lifecycle`, `owner`.
- API: `type`, `lifecycle`, `owner`, `definition`.
- Resource: `type`, `owner`.
- System: `owner`.
- Domain: `owner`.
- Group: `type`, `children`, and the list may be empty.
- User: `memberOf`, and the list may be empty.
- Location: no required field.

The validator checks that an owner is a reference string. It does not check that the owner exists.

The check that a reference points at an accepted entity belongs to the relation step.

An entity with an owner that does not exist is present in the catalog but has a relation that cannot be opened.

## Multi-document files

A line with only `---` separates the documents of a YAML file.

The catalog reads each document as a separate entity and checks it on its own.

One refused document does not stop the other documents of the file from being accepted.

A syntax error is different, because the text cannot be turned into an object. It produces a parse error without an entity name, and the author must fix the text of that document.

## Rules and locations

A location is a pointer to a descriptor file. A file that no location points at is never read.

A location can be registered in static configuration, through the interface or the catalog API, or through a `Location` entity that lists more targets.

Registering a location does not create an entity. The file must still be found, parsed, validated and allowed.

The key `catalog.rules` limits the kinds that the catalog accepts. When the key is present, its list replaces the default list.

A rule on one location adds kinds for the file of that location only, so an organization file can allow `Group` and `User` without opening them for every repository.

A `Location` entity is followed only when its own kind is allowed.

## How to use this when something is missing

Start with the report and not with the source host. A location with the status `not-found` means the URL, the file name or the branch does not match. A parse error means the YAML text is broken. A policy error names a field with a wrong format. A kind error names a missing `spec` field. A rules error means the document is valid but its kind is refused. An unresolved relation means a reference points at an entity that was not accepted.

Fix the earliest stage first, because a document that fails an early check never reaches the later ones.

After each fix, read the report again. The evidence that matters is the list of accepted entities and the list of remaining errors, not a message that a file was saved.

## What stays true after the fix

A valid descriptor describes software. It does not deploy it, grant access to it or prove that it runs.

Credentials do not belong in descriptors, because everyone who can read the repository can read the file.

The owner of a descriptor is the team that maintains the software, and the organization data comes from a separate maintained source.

A population design is good when every entity has a stable name, an owner that exists and a source whose location is registered on purpose.

<!-- astrona:playground:destroy -->
