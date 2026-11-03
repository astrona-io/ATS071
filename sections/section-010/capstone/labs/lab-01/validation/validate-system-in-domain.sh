#!/usr/bin/env bash
# Check: The System shipyard exists, is owned by yard-ops and is part of the Domain logistics
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '([.entities[] | select(.ref == "system:default/shipyard" and .ingested == true) | .relations[] | select(.type == "ownedBy" and .target == "group:default/yard-ops")] | length) == 1 and ([.entities[] | select(.ref == "system:default/shipyard") | .relations[] | select(.type == "partOf" and .target == "domain:default/logistics")] | length) == 1 and ([.entities[] | select(.ref == "domain:default/logistics" and .ingested == true)] | length) == 1' >/dev/null 2>&1; then
  echo "PASS: The System shipyard exists, is owned by yard-ops and is part of the Domain logistics"
  exit 0
fi
echo "FAIL: system:default/shipyard or domain:default/logistics is missing, not owned by yard-ops, or not linked"
exit 1
