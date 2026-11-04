---
draft: true
exam_objectives:
- Using annotations
---
# Tags, Links And Source Annotations

A component page is more useful when it points to the places where people work: the source code, the documentation, the dashboard and the runbook. The catalog has three tools for this, and each one has its own rules. Tags classify an entity, links add named URLs and a few annotations tell plugins where the source and the documentation live. This part separates the three and shows what the validator accepts.

## Tags

`metadata.tags` is a list of short strings that classify an entity, for example `routing` or `experimental`. The catalog uses tags for filters and search. A tag may contain only lowercase letters, digits and the characters `+` and `#`, with single dashes between parts, and it has at most 63 characters. A tag with an uppercase letter or a space fails the field format check, and the entity does not enter the catalog.

## Links

`metadata.links` is a list of objects. The field `url` is required. The fields `title`, `icon` and `type` are optional. A link adds a named URL to the entity page, for example the dashboard of a service. The `icon` value is a key that the frontend maps to an icon. The `type` value groups links in the interface. A link is plain data: the catalog does not check that the address answers.

## Annotations that describe the source

Three annotations describe where the entity lives. The annotation `backstage.io/source-location` points at the folder that holds the source code and has the form `url:https://git.starfleet.example/bridge/tree/main/`. Plugins use it to find files next to the descriptor. The annotations `backstage.io/view-url` and `backstage.io/edit-url` point at the descriptor itself, and the interface uses them for the view and edit buttons. A plugin falls back to the location of the descriptor when these keys are missing.

The annotation `backstage.io/techdocs-ref` points at the documentation source. The value `dir:.` means that the documentation sits next to the descriptor, with its configuration file `mkdocs.yml` in the same folder. The value can also be `url:` followed by an address when the documentation lives in another place. TechDocs reads this annotation and no other field.

<!-- astrona:playground:renew -->

Paste the helper function once:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
```

The component `bridge` has the tag `routing` and four annotations. Read them:

```sh
inspect_catalog -c '.entities[] | select(.ref == "component:default/bridge") | {tags: .metadata.tags, annotations: .metadata.annotations}'
```

The report also shows `backstage.io/managed-by-location`, which the catalog adds and an author never writes.

## Add tags and links to shuttle

Save the text of the file of `shuttle`:

```sh
kubectl -n catalog-source get configmap repo-shuttle -o jsonpath='{.data.catalog-info\.yaml}' > catalog-info.yaml
```

Add the following two blocks to the `metadata` object of `catalog-info.yaml`, at the same indentation as `description`:

```yaml
  tags: [cargo, Experimental]
  links:
    - title: Cargo dashboard
      icon: dashboard
```

Write the file back and read the report:

```sh
kubectl -n catalog-source patch configmap repo-shuttle --type merge -p "$(jq -n --rawfile text catalog-info.yaml '{data: {"catalog-info.yaml": $text}}')"
inspect_catalog -c '.errors[] | select(.entity != null) | {entity, stage, message}'
```

The entity `shuttle` is not ingested, and the report lists an error at the stage `policy`. The policies run one after the other and stop at the first failure, so the report shows one error at a time. The first error names the missing property `url` of the link item. Add `url: https://git.starfleet.example/shuttle/dashboard` to the link item, write the file back and read the errors again. Now the error names the tag `Experimental`, because it has an uppercase letter. Change the tag to `experimental`, write the file back and read `.summary.ingested`. The entity returns, and its `metadata.links` list holds the link.

## What you now know

You can choose between a tag, a link and an annotation for a piece of information, and you can write each so that the validator accepts it. You also know which annotations describe the source and the documentation. The open question is how a plugin treats a key that is valid but wrong, which the earlier annotation checks already showed.

## Common pitfalls

> [!WARNING]
> A tag is not a label: tags have a stricter format and no value. A link without `url` fails validation. The annotation `backstage.io/source-location` needs the `url:` prefix, and a value without it can be rejected by the plugins that read it. The catalog never checks that a link or a source address answers.
