#!/usr/bin/env bash
# Check: The scout Component is registered and ingested
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '.entities[] | select(.ref == "component:default/scout" and .ingested == true)' >/dev/null 2>&1; then
  echo "PASS: The scout Component is registered and ingested"
  exit 0
fi
echo "FAIL: component:default/scout is not ingested"
exit 1
