# Question

Solve this question on: `terminal`

The Starfleet catalog has three Component descriptors, one per repository: `bridge`, `scout` and `shuttle`. Annotations were added by hand and three of the descriptors have mistakes. Repair them so that all three Components are ingested and each annotation points at the right external object. `kubectl` already points at the cluster as the cluster administrator. The descriptors are the ConfigMaps `repo-<name>` in the namespace `catalog-source`.

1. `bridge` must be ingested. The TechDocs source is the directory of its own descriptor; the key is `backstage.io/techdocs-ref` and the value is `dir:.`. The key must be stored where Backstage reads annotations, and no label with that key may remain.
2. The `github.com/project-slug` annotation of `scout` must name the repository of `scout` in the organization `starfleet-org`.
3. The annotations `backstage.io/kubernetes-id` and `backstage.io/kubernetes-label-selector` of `scout` must name `scout`. The selector has the form `app=<name>`.
4. `shuttle` must be ingested. It must keep the annotation `example.com/pager-enabled` with the string value `true`.
5. No annotation on `shuttle` may hold a token or another credential.

Do not delete any repository ConfigMap. Do not change annotations that are already correct, and do not edit the ConfigMap `catalog-config`.
