#!/usr/bin/env bash
# Check: The scanner file parses and the Component is accepted
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '([.errors[] | select(.stage == "parse")] | length == 0) and (.entities[] | select(.ref == "component:default/scanner" and .ingested == true))' >/dev/null 2>&1; then
  echo "PASS: The scanner file parses and the Component is accepted"
  exit 0
fi
echo "FAIL: the scanner file has a parse error or component:default/scanner is not ingested"
exit 1
