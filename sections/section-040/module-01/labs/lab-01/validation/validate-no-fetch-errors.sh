#!/usr/bin/env bash
# Check: No location fails to fetch
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '([.errors[] | select(.stage == "fetch")] | length) == 0' >/dev/null 2>&1; then
  echo "PASS: No location fails to fetch"
  exit 0
fi
echo "FAIL: at least one location still fails to fetch"
exit 1
