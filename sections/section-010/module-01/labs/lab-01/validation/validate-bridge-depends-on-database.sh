#!/usr/bin/env bash
# Check: The bridge Component depends on the resource telemetry-db and the relation resolves
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '([.entities[] | select(.ref == "component:default/bridge" and .ingested == true) | .relations[] | select(.type == "dependsOn" and .target == "resource:default/telemetry-db")] | length) == 1 and ([.entities[] | select(.ref == "resource:default/telemetry-db" and .ingested == true)] | length) == 1' >/dev/null 2>&1; then
  echo "PASS: The bridge Component depends on the resource telemetry-db and the relation resolves"
  exit 0
fi
echo "FAIL: bridge does not have a resolved dependsOn relation to resource:default/telemetry-db"
exit 1
