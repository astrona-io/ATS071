#!/usr/bin/env bash
# Check: Both fleet components are ingested through the Location entity
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '([.entities[] | select(.ingested == true and (.ref == "component:default/shuttle" or .ref == "component:default/cargo-hauler"))] | length) == 2 and ([.config.locations[] | select(.target | test("fleet-registry/blob/main/(shuttle|cargo)"))] | length) == 0' >/dev/null 2>&1; then
  echo "PASS: Both fleet components are ingested through the Location entity"
  exit 0
fi
echo "FAIL: shuttle or cargo-hauler is not ingested, or a fleet file was registered directly in catalog.locations"
exit 1
