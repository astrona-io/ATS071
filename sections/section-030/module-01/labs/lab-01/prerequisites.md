# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `jq`.
- You know the terms used in the task. The reading parts of this module explain them.

The lab starts a single-node kind cluster (Kubernetes 1.35). The descriptor files are stored as ConfigMaps in the namespace `catalog-source`, and a pod in `catalog-tools` checks them with the `@backstage/catalog-model` library, the library that the Backstage catalog backend uses. The lab does not run the Backstage application. The cluster needs internet access to pull the `node:22-alpine` image and to install two npm packages. The task is on the next page.
