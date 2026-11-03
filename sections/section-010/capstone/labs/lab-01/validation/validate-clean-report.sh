#!/usr/bin/env bash
# Check: The catalog has no processing errors and no unresolved relations
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '.summary.errorCount == 0 and (.unresolved | length) == 0' >/dev/null 2>&1; then
  echo "PASS: The catalog has no processing errors and no unresolved relations"
  exit 0
fi
echo "FAIL: the report still has errors or unresolved relations"
exit 1
