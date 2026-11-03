#!/usr/bin/env bash
# Check: The drifter descriptor parses and is ingested
set -uo pipefail
fail=0

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi


if ! echo "$report" | jq -e '.entities[] | select(.ref == "component:default/drifter" and .ingested == true)' >/dev/null; then
  echo "FAIL: component:default/drifter is not ingested; errors: $(echo "$report" | jq -c '[.errors[] | select(.location | contains("/drifter/")) | .message]')"
  fail=1
fi

if [ "$fail" -eq 0 ]; then echo "PASS: The drifter descriptor parses and is ingested"; fi
exit "$fail"
