---
draft: true
exam_objectives:
- Understand how/why to use Backstage Catalog
---
# Component Type And Lifecycle

A list of components says little until each one tells what it is and how mature it is. Two required fields of the `Component` kind do this: `spec.type` and `spec.lifecycle`. This part explains both fields, shows that the catalog validates their presence and not their values, and reads them in the playground.

## What the two fields mean

The field `spec.type` says what kind of software the component is. Common values are `service`, `website` and `library`. The field `spec.lifecycle` says in which stage of its life the component is. The values that the Backstage documentation names are `experimental`, `production` and `deprecated`. Both fields are required for a component, and a component without either one fails validation.

The catalog does not restrict the values. The text `retired` or `prod` is accepted as a lifecycle, and a page that filters by `production` then misses the component. Plugins and organizations often fix a list of allowed values and check it outside the catalog. Within this module, the three named lifecycle values are the standard.

## Read the fields

<!-- astrona:playground:renew -->

Paste the helper function once:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

Print the type, lifecycle and owner of every component:

```sh
inspect_catalog -c '.entities[] | select(.kind == "Component") | {ref, type: .spec.type, lifecycle: .spec.lifecycle, owner: .spec.owner}'
```

The estate has four components. `scout` is a `website` with the lifecycle `experimental`. The other three are services, and `probe` has the lifecycle `deprecated`.

## A missing lifecycle

Save the file of the `shuttle` repository:

```sh
kubectl -n catalog-source get configmap repo-shuttle -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
```

Remove the line `lifecycle: production` and apply the file:

```sh
kubectl -n catalog-source create configmap repo-shuttle --from-file=catalog-info.yaml --dry-run=client -o yaml | kubectl apply -f -
```

Then read the errors:

```sh
inspect_catalog -c '.errors[] | {entity, stage, message}'
```

The error is at the stage `kind`. The kind schema of the component names the missing property `lifecycle`, and `shuttle` is no longer in `.summary.ingested`. Put the line back and apply the file again.

## A value that validates and still misleads

Change the lifecycle of `shuttle` to `prod` and apply the file. The entity stays ingested, because the catalog accepts any string. Filter by the value `production` and `shuttle` is missing from the result. The catalog gave no error, so only a person who reads the data finds the mistake. Change the value back to `production`.

## What you now know

You know the two required fields, the common values and the fact that the catalog checks the presence of a value and not its meaning. The open question is how to use these fields to find software, which the next reading answers.

## Common pitfalls

> [!WARNING]
> Both fields are required, but any string is accepted. A lifecycle such as `prod` or `retired` is valid and breaks filters. Do not treat a lifecycle as a status that the catalog keeps current: the author sets it by hand.
