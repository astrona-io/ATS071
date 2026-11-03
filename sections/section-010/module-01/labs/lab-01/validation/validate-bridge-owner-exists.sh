#!/usr/bin/env bash
# Check: The bridge Component is ingested and owned by the Group starfleet-ops
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '([.entities[] | select(.ref == "component:default/bridge" and .ingested == true) | .relations[] | select(.type == "ownedBy" and .target == "group:default/starfleet-ops")] | length) == 1 and ([.unresolved[] | select(.from == "component:default/bridge" and .type == "ownedBy")] | length) == 0' >/dev/null 2>&1; then
  echo "PASS: The bridge Component is ingested and owned by the Group starfleet-ops"
  exit 0
fi
echo "FAIL: bridge is not ingested or its ownedBy relation does not point at group:default/starfleet-ops"
exit 1
