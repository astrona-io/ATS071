---
draft: true
exam_objectives:
- Working with manually registered entity locations
---
# Summary
 A location is the address of a descriptor file, made of a type and a target.
A person registers it by hand in one of two places. The static configuration
key `catalog.locations` belongs to the deployment and changes only through a
new configuration. A registration through the catalog interface or the catalog
API is stored in the catalog database and can be removed through the same
interface unless the catalog is read only. A location from the static
configuration cannot be removed through the API.

The catalog backend does the work after registration. A URL reader fetches the
file with the credentials of the backend integration, which can differ from
the access of the person who registered it. The backend then parses the file,
validates every document, applies the rules for allowed kinds, resolves
relations and publishes the entities. An accepted registration only records an
input. A missing file, a wrong branch, a missing credential, a rule that
refuses a kind and a broken relation each leave a different error, and each
has a different repair.

An entity of the kind `Location` turns one registration into a tree. Its
`spec.target` or `spec.targets` list absolute addresses or relative paths. A
relative path resolves against the file that holds the `Location` entity. Each
listed file goes through the same stages as a registered one, and a failure of
one target leaves the others in place.

The rules decide which kinds a file may contain. Without a `catalog.rules`
key, the default list allows `Component`, `System`, `API`, `Resource` and
`Location`. A `catalog.rules` key replaces that list. A `rules` key on a
static location adds kinds for the file at that location only, and files
reached through a `Location` entity use the global rules only.

The published entity follows its source. The catalog processes each entity
again on a schedule, and it records the location that maintains it in the
annotation `backstage.io/managed-by-location`. Deleting a published entity
that still has a parent does not last, because the next pass publishes it
again. Retiring software means changing the descriptor, the `Location` entity
or the registration.

An entity that loses its parent becomes an orphan and carries the annotation
`backstage.io/orphan`. By default the catalog removes orphans. The setting
`catalog.orphanStrategy: keep` keeps them until someone deletes them. A
missing or unreadable file does not orphan its entities, and an orphan marker
does not prove that the software stopped running.

Reading a catalog that does not show an expected entity follows a fixed order.
First ask whether a location exists for the file, either registered by hand or
listed by a Location entity. Then ask whether the backend can read the file.
Then ask whether the file is valid YAML and whether each document passes
validation. Then ask whether a rule allows the kind from that location. Last,
ask whether another file declares the same entity reference.

The order works because each question rules out one component. The
registration belongs to the person or the configuration. The fetch belongs to
the URL reader and its credentials. The validation belongs to the entity
policies and the kind validators. The rules belong to the catalog
configuration. The conflict belongs to the two descriptors. Naming the
component that failed leads straight to the person who can fix it.

Ownership of the source also matters. A Location entity that lists files in
several repositories gives one team control over what other teams publish. A
static location in the deployment configuration gives the platform team that
control. A registration through the interface gives it to whoever pressed the
button. A clear rule about who registers what keeps the catalog free of
duplicates and of entries that nobody maintains.

Two failure habits explain most trouble with manual registration. The first
habit is to treat the registration screen as the end of the task. The person
sees a success message and does not look at the processing result, so a wrong
branch or a refused kind stays unnoticed for weeks. The second habit is to
treat the interface as the place to repair the catalog. A person deletes an
entity that is wrong, and the entity returns, because the source still
produces it.

The remedy for both is to read the evidence of each stage and to change the
stage that failed. A fetch error is repaired in the address or the
credentials. A rule error is repaired in the rules. A conflict is repaired by
removing one of the two declarations. A retirement is repaired in the
descriptor or the registration.

Key facts to remember:

- Registration, fetching, processing and publication are separate stages with separate errors.
- Static locations are removed through the configuration, and API locations through the API.
- Per-location rules do not reach files listed by a `Location` entity.
- Two declarations of one entity reference conflict, and only one location keeps the entity.
- Retire software at the source, not on the published record.

<!-- astrona:playground:destroy -->
