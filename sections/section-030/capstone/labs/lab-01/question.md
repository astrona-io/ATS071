# Question

Solve this question on: `terminal`

The Starfleet catalog has four Component descriptors, one per repository: `bridge`, `scout`, `shuttle` and `probe`. A review found annotation mistakes in all four. Repair them so that every Component is ingested and every integration finds the right external object. `kubectl` already points at the cluster as the cluster administrator. The descriptors are the ConfigMaps `repo-<name>` in the namespace `catalog-source`.

1. `probe` must be ingested. Its on-call link must stay as an annotation, under a key that is valid. Use the key `example.com/oncall-schedule`.
2. No annotation on `probe` may hold a password or token.
3. The `github.com/project-slug` annotation of `bridge` must use the format `<owner>/<repository>`. The repository is `bridge` in the organization `starfleet-org`.
4. `scout` must declare the TechDocs source as the directory of its own descriptor, and its source location as the folder `https://git.starfleet.example/scout/tree/main/`, written in the form that Backstage expects for the `backstage.io/source-location` annotation.
5. `shuttle` copied annotations from `bridge`. Its project slug, its `backstage.io/kubernetes-id` and its `backstage.io/view-url` must name `shuttle` and its own descriptor file on the `main` branch.
6. `shuttle` must be ingested. Its lifecycle is `production` and must be stored where Backstage reads a lifecycle, not in an annotation.

Do not delete any repository ConfigMap. Do not change the annotations that are already correct, and do not edit the ConfigMap `catalog-config`.
