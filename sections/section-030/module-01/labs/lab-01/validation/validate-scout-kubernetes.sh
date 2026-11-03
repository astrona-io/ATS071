#!/usr/bin/env bash
# Check: The scout Component maps to its own Kubernetes workloads
set -uo pipefail
fail=0

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi


if ! echo "$report" | jq -e '.entities[] | select(.ref == "component:default/scout" and .ingested == true) | select(.metadata.annotations["backstage.io/kubernetes-id"] == "scout" and .metadata.annotations["backstage.io/kubernetes-label-selector"] == "app=scout")' >/dev/null; then
  echo "FAIL: scout must carry backstage.io/kubernetes-id and backstage.io/kubernetes-label-selector values that name scout"
  fail=1
fi
if [ "$fail" -eq 0 ]; then echo "PASS: The scout Component maps to its own Kubernetes workloads"; fi
exit "$fail"
