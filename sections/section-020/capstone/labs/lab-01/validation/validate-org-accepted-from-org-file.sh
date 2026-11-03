#!/usr/bin/env bash
# Check: The groups and the user of the organization file are accepted
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '([.entities[] | select((.ref == "group:default/dockworkers" or .ref == "group:default/ops-team" or .ref == "user:default/mara") and .ingested == true)] | length == 3)' >/dev/null 2>&1; then
  echo "PASS: The groups and the user of the organization file are accepted"
  exit 0
fi
echo "FAIL: dockworkers, ops-team or mara is not ingested"
exit 1
