#!/usr/bin/env bash
# Check: The cargo Component and the cargo-api API are accepted and the API reference resolves
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '([.entities[] | select((.ref == "component:default/cargo" or .ref == "api:default/cargo-api") and .ingested == true)] | length == 2) and ([.unresolved[] | select(.from == "component:default/cargo")] | length == 0)' >/dev/null 2>&1; then
  echo "PASS: The cargo Component and the cargo-api API are accepted and the API reference resolves"
  exit 0
fi
echo "FAIL: component:default/cargo or api:default/cargo-api is not ingested, or providesApis does not resolve"
exit 1
