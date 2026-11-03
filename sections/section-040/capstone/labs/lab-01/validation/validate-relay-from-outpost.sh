#!/usr/bin/env bash
# Check: outpost-relay is ingested from the outpost repository
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '.entities[] | select(.ref == "component:default/outpost-relay" and .ingested == true and (.metadata.annotations["backstage.io/managed-by-location"] | test("outpost/blob")))' >/dev/null 2>&1; then
  echo "PASS: outpost-relay is ingested from the outpost repository"
  exit 0
fi
echo "FAIL: outpost-relay is not ingested, or it is managed by another location"
exit 1
