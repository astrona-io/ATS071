---
draft: true
exam_objectives:
- Working with automated ingestion
---
# More Providers And Organization Data

One provider is rarely enough. A company has repositories in GitHub, some in GitLab or Azure DevOps, and people and teams in an identity system. Each source needs its own entity provider, and each provider has its own configuration under `catalog.providers`. This part lists the common providers, explains how organization data differs from repository discovery and shows what happens when two providers reach the same file.

## Providers by source

A provider is a backend module. It reads one external source and tells the catalog which entities exist. The GitHub provider, configured under `catalog.providers.github`, discovers descriptor files in repositories. The GitHub organization provider, configured under `catalog.providers.githubOrg`, ingests users and teams as `User` and `Group` entities. Other modules do the same for GitLab, Azure DevOps and Bitbucket Cloud. The names of the keys change from source to source, and the idea stays the same: a provider has an id, a source filter, a path and a schedule.

Each provider id is the name of one configuration block. A real backend uses it as part of the name of the provider. If a block is renamed, the backend sees a new provider, and the entities of the old provider are no longer maintained by anything. The playground model shows the id in the origin of each discovered location.

## Repository discovery and organization data

Repository discovery finds files that people maintain next to their code. Organization data comes from an identity system, and nobody writes a file for it. The distinction matters for the rules. A discovered `Component` is allowed by the default rules. A `User` or a `Group` is not, so the global `catalog.rules` list must allow the kinds that an organization provider writes.

## Two providers, one repository

Two provider blocks can match the same repository. Both providers then produce a location for the same file. The entities in the file are declared twice, and the catalog keeps one claim and reports the other as a conflict.

<!-- astrona:playground:renew -->

Paste the helper functions once:

```sh
inspect_catalog() {
  kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js | jq "$@"
}
save_app_config() {
  kubectl -n catalog-source get configmap catalog-config -o jsonpath='{.data.app-config\.yaml}' > app-config.yaml
}
apply_app_config() {
  kubectl -n catalog-source create configmap catalog-config --from-file=app-config.yaml --dry-run=client -o yaml | kubectl apply -f -
}
```

Save the configuration:

```sh
save_app_config
```

Add a second provider block next to `starfleetServices`, at the same indentation, inside `providers.github`:

```yaml
          scoutOnly:
            organization: starfleet
            catalogPath: /catalog-info.yaml
            filters:
              repository: '^scout$'
              branch: main
            schedule:
              frequency: { minutes: 30 }
              timeout: { minutes: 3 }
```

Apply the configuration and read the locations and conflicts:

```sh
apply_app_config
inspect_catalog -c '[.locations[] | select(.target | contains("/scout/")) | {origin, target}]'
inspect_catalog -c '.conflicts'
```

The model reads each address once, so the location of `scout` appears one time, and the report shows no conflict. A real backend keeps the output of each provider apart, so two providers that emit the same entity produce a conflict there. The model cannot show that case. It can show the same problem through a static location. Add a static location for `legacy-info.yaml` of `scout` under `catalog.locations`, as the playground tasks describe, and the conflict list shows the two files that declare the same entity reference.

The lesson is that overlapping sources are a design problem. Give each repository one owner of its registration, and use filters so that two provider blocks never match the same repository.

## What you now know

You know that each source has its own provider and configuration, that the provider id names a block, that organization data needs rules that allow its kinds and that overlapping sources lead to duplicates. The open question is how a custom source is added when no module exists for it.

## Common pitfalls

> [!WARNING]
> Renaming a provider id creates a new provider in a real backend. Organization kinds are not allowed by the default rules. Two providers or a provider and a static location that reach the same file produce duplicate claims. A model run never contacts the source, so it cannot show credentials or rate limit problems.
