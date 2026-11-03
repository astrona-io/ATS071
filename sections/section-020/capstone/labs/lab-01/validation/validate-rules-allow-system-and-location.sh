#!/usr/bin/env bash
# Check: System and Location entities are allowed and accepted
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '(.entities[] | select(.ref == "system:default/harbor" and .ingested == true)) and (.entities[] | select(.kind == "Location" and .ingested == true))' >/dev/null 2>&1; then
  echo "PASS: System and Location entities are allowed and accepted"
  exit 0
fi
echo "FAIL: system:default/harbor or the Location entity is not ingested"
exit 1
