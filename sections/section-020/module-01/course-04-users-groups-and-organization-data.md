---
draft: true
exam_objectives:
- Populate Backstage Catalog
---
# Users, Groups And Organization Data

Components need owners, and owners are `Group` and `User` entities. If the catalog holds no organization data, every `owner` field points at nothing and the ownership pages stay empty. This part shows how to describe teams and people in descriptor files, which fields each kind requires and how the catalog treats a reference to a person or team that does not exist.

## The two organization kinds

A `Group` entity describes a team, a department or any other unit of people. Its `spec.type` is required and is a free string, for example `team` or `department`. Its `spec.children` list is required, even when it is empty, and it holds the groups below it. The optional fields are `spec.parent`, `spec.members` and `spec.profile`. The `profile` object can hold `displayName`, `email` and `picture`.

A `User` entity describes one person. Its `spec` object may be empty, but `spec.memberOf` is the usual field, and it lists the groups of the user. The optional `spec.profile` has the same `displayName`, `email` and `picture` fields. A user name must follow the same format rules as every entity name: letters, digits, `-`, `_` and `.`, at most 63 characters.

The catalog derives relations from these fields. A user with `memberOf` gets a `memberOf` relation, and the group gets a `hasMember` relation. A group with `parent` gets `childOf`, and the parent gets `parentOf`. A component with `owner: starfleet-ops` gets an `ownedBy` relation to `group:default/starfleet-ops`.

## Where organization data comes from

Small estates write the organization file by hand, as the playground does. Larger estates do not, because teams change every week. They ingest users and groups from an identity source such as GitHub, LDAP, Microsoft Entra ID or Okta, through an entity provider that is a separate backend module. A provider writes the same `User` and `Group` entities that a person would write in a file.

The rule from the earlier parts still applies. The default rules allow `Component`, `System`, `API`, `Resource` and `Location`, but not `Group` or `User`. A location that holds organization data needs a rule that allows both kinds. A rule on the location of the file does this without opening the kinds for every other location.

<!-- astrona:playground:renew -->

The playground has the file `org.yaml` in the repository `starfleet-org`, with two groups and the user `kira`. The location of that file carries the rule `allow: [Group, User]`. Paste the helper function once:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

Print the relations of the organization entities:

```sh
inspect_catalog -c '.entities[] | select(.kind == "Group" or .kind == "User") | {ref, relations}'
```

The user `kira` has a `memberOf` relation to `group:default/starfleet-ops`. The groups have no relations yet, because both have an empty `children` list and no parent.

## Add a team below a group

Save the text of the organization file:

```sh
kubectl -n catalog-source get configmap repo-starfleet-org -o jsonpath='{.data.org\.yaml}' > org.yaml
```

Save a new group as `group-navigators.yaml`:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: navigators
  description: Plans routes for the bridge
spec:
  type: team
  parent: starfleet-ops
  children: []
  profile:
    displayName: Navigators
```

Append it to `org.yaml` and write the file back:

```sh
printf -- '---\n' >> org.yaml
cat group-navigators.yaml >> org.yaml
kubectl -n catalog-source patch configmap repo-starfleet-org --type merge -p "$(jq -n --rawfile text org.yaml '{data: {"org.yaml": $text}}')"
```

Then check the result:

```sh
inspect_catalog -c '.entities[] | select(.ref == "group:default/navigators") | {ingested, relations}'
```

The group is ingested and has a `childOf` relation to `group:default/starfleet-ops`. The parent has no `children` entry for `navigators`. The real catalog still derives a `parentOf` relation on the parent from the `parent` field of the child, so the lists do not have to agree.

## A reference to a missing group

Change the `parent` of `navigators` to `starfleet-command`, a group that no file declares, and write the file back in the same way. Then print the unresolved relations:

```sh
inspect_catalog -c '.unresolved'
```

The entry for `childOf` with the target `group:default/starfleet-command` appears. The group passes validation, because the catalog does not look up targets while it validates. It stays in the catalog with a relation that points at nothing. The same happens when a `User` names a group in `memberOf` that does not exist.

## What you now know

You can describe teams and people with the two organization kinds, give each the required fields, build a hierarchy with `parent` and `children`, and let a location rule admit the kinds without widening the global rules. You can also tell a validation error from an unresolved relation. The open question is who keeps this data current, which is the job of an ingestion source and not of a one-time file.

## Common pitfalls

> [!WARNING]
> A `Group` without `spec.children` fails validation, even when the list would be empty. A `User` or `Group` document is not ingested from a location whose rules do not allow the kind. A missing parent or member group leaves an unresolved relation and no validation error, so check `.unresolved` as well as `.errors`.
