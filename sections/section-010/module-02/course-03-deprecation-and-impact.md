---
draft: true
exam_objectives:
- Understand how/why to use Backstage Catalog
---
# Deprecation And Impact

Software reaches the end of its life, and the lifecycle `deprecated` tells readers to stop starting new uses. Marking a component is the first step. The second step is to find who still uses it. This part follows a deprecation through the `dependsOn` relations.

## What deprecated tells and what it does not

A component with the lifecycle `deprecated` still runs, and the catalog still lists it. The value is a signal to people. The catalog does not stop other components from depending on it, and it does not remove the component. Removal is a separate decision in the descriptor or the registration.

The direct users of a component are the components whose `spec.dependsOn` names it. The catalog stores the reverse relation `dependencyOf` on the target, so the page of `probe` can list its dependents. The checker in the playground prints only the forward relations, so you find the dependents by searching for them.

<!-- astrona:playground:renew -->

Paste the helper function once:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

List the deprecated entities:

```sh
inspect_catalog -r '.entities[] | select(.spec.lifecycle == "deprecated") | .ref'
```

Find the entities that depend on `component:default/probe`:

```sh
inspect_catalog -r '.entities[] | select(any(.relations[]?; .type == "dependsOn" and .target == "component:default/probe")) | .ref'
```

The result is `component:default/shuttle`. The owners of `shuttle` are the people to tell before `probe` is removed.

## Check what the removal would break

Remove the location of `probe` from `catalog-config`. Save the configuration, delete the item of the `locations` list that points at the `probe` repository, and apply it:

```sh
kubectl -n catalog-source get configmap catalog-config -o yaml > catalog-config.yaml
kubectl apply -f catalog-config.yaml
```

Then read the unresolved relations:

```sh
inspect_catalog -c '.unresolved'
```

The report lists a `dependsOn` relation from `shuttle` to `component:default/probe`. The reference is valid, and its target is gone. This is the state that a removal without a check leaves behind. Add the location back and apply the file again.

## A retirement order

A safe order has four steps. Set the lifecycle to `deprecated`. Find the dependents and ask their owners to remove the dependency. Remove the registration or the descriptor. Check the unresolved relations for the old reference.

## What you now know

You can mark software as deprecated, find the components that still depend on it and read the damage that a removal causes. The open question is how to find these problems before an incident, which is the work of an audit.

## Common pitfalls

> [!WARNING]
> The lifecycle `deprecated` does not block new dependencies. Removing a registration leaves the `dependsOn` relations of other components unresolved. Search the dependents before you remove anything.
