#!/usr/bin/env bash
# Check: The sensor-array Component is ingested from its absolute target
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '.entities[] | select(.ref == "component:default/sensor-array" and .ingested == true)' >/dev/null 2>&1; then
  echo "PASS: The sensor-array Component is ingested from its absolute target"
  exit 0
fi
echo "FAIL: component:default/sensor-array is not ingested"
exit 1
