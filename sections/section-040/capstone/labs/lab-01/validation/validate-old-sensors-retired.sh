#!/usr/bin/env bash
# Check: old-sensors is gone and the rest of the services file remains
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '([.entities[] | select(.name == "old-sensors")] | length) == 0 and ([.entities[] | select(.ref == "component:default/helm" and .ingested == true)] | length) == 1' >/dev/null 2>&1; then
  echo "PASS: old-sensors is gone and the rest of the services file remains"
  exit 0
fi
echo "FAIL: old-sensors is still declared, or helm was removed"
exit 1
