#!/usr/bin/env bash
# Check: The internal bridge is discovered and the private vault is not
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '.summary.ingested | (index("component:default/bridge") != null) and (index("component:default/vault") == null)' >/dev/null 2>&1; then
  echo "PASS: The internal bridge is discovered and the private vault is not"
  exit 0
fi
echo "FAIL: component:default/bridge is not ingested, or component:default/vault is ingested"
exit 1
