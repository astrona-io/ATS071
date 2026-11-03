#!/usr/bin/env bash
# Check: The API gate-api exists in the System shipyard and the gate Component provides it
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '([.entities[] | select(.ref == "api:default/gate-api" and .ingested == true) | .relations[] | select(.type == "partOf" and .target == "system:default/shipyard")] | length) == 1 and ([.entities[] | select(.ref == "component:default/gate" and .ingested == true) | .relations[] | select(.type == "providesApi" and .target == "api:default/gate-api")] | length) == 1' >/dev/null 2>&1; then
  echo "PASS: The API gate-api exists in the System shipyard and the gate Component provides it"
  exit 0
fi
echo "FAIL: gate-api is missing, not in shipyard, or gate does not provide it"
exit 1
