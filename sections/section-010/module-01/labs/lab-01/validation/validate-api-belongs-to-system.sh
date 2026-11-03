#!/usr/bin/env bash
# Check: The bridge-api API is part of the System navigation
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '([.entities[] | select(.ref == "api:default/bridge-api" and .ingested == true) | .relations[] | select(.type == "partOf" and .target == "system:default/navigation")] | length) == 1 and ([.unresolved[] | select(.from == "api:default/bridge-api")] | length) == 0' >/dev/null 2>&1; then
  echo "PASS: The bridge-api API is part of the System navigation"
  exit 0
fi
echo "FAIL: bridge-api does not have a resolved partOf relation to system:default/navigation"
exit 1
