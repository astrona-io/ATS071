#!/usr/bin/env bash
# Check: No entity is claimed by two locations
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '(.conflicts | length) == 0' >/dev/null 2>&1; then
  echo "PASS: No entity is claimed by two locations"
  exit 0
fi
echo "FAIL: at least one entity reference is declared in two places"
exit 1
