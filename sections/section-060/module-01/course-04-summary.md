---
draft: true
exam_objectives:
- Working with automated ingestion
---
# Summary

Automated ingestion lets the catalog fill itself from the systems where
descriptor files already live. It replaces manual registration with code that
runs repeatedly and keeps the catalog close to its sources.

## Providers and processors

An entity provider is the original source of entities. It decides when to
fetch data and what to hand to the catalog. A processor works on entities that
the catalog already holds. It validates them, adds annotations and derives
relations.

Each provider has a name that must be unique and stable. The backend stores
the entities of one provider together under that name. A renamed provider is a
new provider to the backend.

When an entity is missing, first decide which role failed. If the provider
built no location, the cause is the provider configuration. If the location
exists and the entity is missing, the cause is in processing.

## GitHub discovery

GitHub discovery is a provider from the package
`@backstage/plugin-catalog-backend-module-github`. Each entry under
`catalog.providers.github` is one provider with its own id. The entry names an
organization, a `catalogPath` and filters. The default path is
`/catalog-info.yaml`.

The provider lists the repositories, removes the ones that fail a filter and
builds one location for each remaining repository. The backend fetches those
locations and processes the entities like any other location.

## Scope

The filters decide what the catalog contains. A repository must pass every
filter that is set. The filters are the branch, the repository name pattern,
the topics to include or exclude, the visibility and whether archived
repositories count.

A topic in the exclude list wins over the same topic in the include list. The
filters read repository metadata, so a change at the source changes the
catalog without any change to the configuration.

A narrow scope with an opt-in topic is a safer default than a wide pattern.
Review a filter change like any change to production configuration.

## Credentials

The provider needs permission to read the repositories. GitHub accepts a
personal access token with the `repo` scope or a GitHub App with read access
to contents. The credential belongs in the protected configuration of the
backend and never in a descriptor.

The credential limits what the backend can read. The filters limit what enters
the catalog. Give the credential the smallest scope that covers the
organization.

## Schedule and load

The schedule has a frequency and a timeout, and optionally an initial delay
and a scope. A short frequency gives fresh data and sends many requests. The
provider makes one request for each discovered location on every refresh, and
the hourly rate limit is shared with other tools.

Events from GitHub shorten the delay after a push. They do not replace the
schedule, because a missed event must still be repaired by a later run.

## Full and delta updates

A full mutation replaces everything that the provider owns. An entity that a
full mutation leaves out is removed. A delta mutation adds or removes named
entities and leaves the rest alone.

An incomplete run that is sent as a full mutation turns a temporary failure
into deletion. A good provider reports the failed run and keeps the previous
set. The backend can also remove entities of a provider that is no longer
configured, and orphans, unless the clean-up strategy is set to keep them.

## Duplicate sources

No two providers can safely emit the same entity. The backend rejects the
second claim and reports a conflict. A static location from an old setup that
reads a file with the same entity as a provider is a common cause.

Decide which source owns each entity and remove the other. Changing a title or
a description does not change the identity of the entity.

## Key facts

- A provider creates input for the catalog; a processor works on entities that
  the catalog already holds.
- The provider id and the provider name must be stable.
- A discovered location has the origin `provider:github:<id>` in the model.
- The default `catalogPath` is `/catalog-info.yaml`.
- Every filter that is set must pass for a repository to be discovered.
- Topic exclusion wins over topic inclusion.
- Visibility takes the values public, internal and private.
- A change to repository metadata changes the catalog.
- A credential is not a filter and a filter is not a credential.
- The schedule needs a frequency and a timeout.
- A short frequency can use up the shared rate limit.
- Events shorten the delay; the schedule repairs missed events.
- A full mutation removes what the run leaves out.
- A static location and a provider that claim one entity cause a conflict.
- Automatic removal needs a policy for missing and orphaned entities.
- The labs model the catalog backend and do not run Backstage.

<!-- astrona:playground:destroy -->
