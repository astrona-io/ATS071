#!/usr/bin/env bash
# Check: The Resource dock-db exists in shipyard and the gate Component depends on it
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '([.entities[] | select(.ref == "resource:default/dock-db" and .ingested == true) | .relations[] | select(.type == "partOf" and .target == "system:default/shipyard")] | length) == 1 and ([.entities[] | select(.ref == "component:default/gate" and .ingested == true) | .relations[] | select(.type == "dependsOn" and .target == "resource:default/dock-db")] | length) == 1' >/dev/null 2>&1; then
  echo "PASS: The Resource dock-db exists in shipyard and the gate Component depends on it"
  exit 0
fi
echo "FAIL: dock-db is missing, not in shipyard, or gate does not depend on it"
exit 1
