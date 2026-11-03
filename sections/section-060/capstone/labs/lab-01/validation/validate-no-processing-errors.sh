#!/usr/bin/env bash
# Check: The report has no errors and the catalog has all six expected entities
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '(.summary.errorCount == 0) and ((.summary.ingested | length) >= 6)' >/dev/null 2>&1; then
  echo "PASS: The report has no errors and the catalog has all six expected entities"
  exit 0
fi
echo "FAIL: the report still lists errors, or an expected entity is missing"
exit 1
