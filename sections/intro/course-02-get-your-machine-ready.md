# Get Your Machine Ready

The playgrounds and labs run on your own computer. This page lists what to install and the `astrona` commands you will use every day.

## What to install

You need these tools:

- A container engine that kind can use, Docker or Podman. Plan for about 2 GiB of free memory.
- `kubectl`, the Kubernetes command-line client.
- `jq`, a tool that filters JSON. The playgrounds print JSON reports and you filter them with `jq`.
- The `astrona` command-line tool.

Run `astrona check` after you install it. The command tells you if something is missing.

## What the environment is

The playgrounds and labs start a single-node Kubernetes cluster with kind (Kubernetes in Docker). They do not run the Backstage application. The descriptor files live in ConfigMaps, which are Kubernetes objects that hold text files. A small pod runs a checker script. The script validates the files with `@backstage/catalog-model`, the library that the Backstage catalog backend uses, and models how the catalog reads locations, applies rules and builds relations. The cluster needs internet access to pull the `node:22-alpine` image and to install two npm packages when the pod starts.

## Commands you use every day

Start a playground from the repository root of the course:

```sh
astrona run -c <path-to-playground>
```

Stop and remove it with `astrona destroy <environment-name>`. A lab uses `astrona run` to start, `astrona submit` to grade and `astrona destroy` to remove it. Add `--keep` to `astrona submit` to keep the lab running after a failed check.

## When a start goes wrong

If `astrona run` fails, read the last message first. A full disk, a stopped container engine and too little memory are the usual causes. Run `astrona destroy` for the environment and start again. If the checker pod never becomes ready, check that the cluster can reach the internet, because the pod installs two npm packages at start.
