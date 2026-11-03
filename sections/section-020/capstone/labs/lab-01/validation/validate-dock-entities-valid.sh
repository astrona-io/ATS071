#!/usr/bin/env bash
# Check: dock-gate and dock-api are accepted and the API reference resolves
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '([.entities[] | select((.ref == "component:default/dock-gate" or .ref == "api:default/dock-api") and .ingested == true)] | length == 2) and ([.unresolved[] | select(.from == "component:default/dock-gate")] | length == 0)' >/dev/null 2>&1; then
  echo "PASS: dock-gate and dock-api are accepted and the API reference resolves"
  exit 0
fi
echo "FAIL: component:default/dock-gate or api:default/dock-api is not ingested, or providesApis does not resolve"
exit 1
