#!/usr/bin/env bash
# Check: The shuttle Component carries its own identity annotations
set -uo pipefail
fail=0

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi


if ! echo "$report" | jq -e '.entities[] | select(.ref == "component:default/shuttle" and .ingested == true) | select(.metadata.annotations["github.com/project-slug"] == "starfleet-org/shuttle" and .metadata.annotations["backstage.io/kubernetes-id"] == "shuttle" and (.metadata.annotations["backstage.io/view-url"] | tostring | contains("/shuttle/")))' >/dev/null; then
  echo "FAIL: shuttle must be ingested and its project slug, Kubernetes id and view URL must name shuttle"
  fail=1
fi
if [ "$fail" -eq 0 ]; then echo "PASS: The shuttle Component carries its own identity annotations"; fi
exit "$fail"
