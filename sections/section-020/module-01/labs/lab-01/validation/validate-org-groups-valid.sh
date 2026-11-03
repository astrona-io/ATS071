#!/usr/bin/env bash
# Check: The group starfleet-ops is accepted and its members resolve
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '(.entities[] | select(.ref == "group:default/starfleet-ops" and .ingested == true)) and ([.unresolved[] | select(.target == "group:default/starfleet-ops")] | length == 0)' >/dev/null 2>&1; then
  echo "PASS: The group starfleet-ops is accepted and its members resolve"
  exit 0
fi
echo "FAIL: group:default/starfleet-ops is not ingested"
exit 1
