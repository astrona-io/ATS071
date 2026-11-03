#!/usr/bin/env bash
# Check: A Group declared in the harbor repository is still not accepted
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '[.entities[] | select(.ref == "group:default/rogue-admins" and .ingested == true)] | length == 0' >/dev/null 2>&1; then
  echo "PASS: A Group declared in the harbor repository is still not accepted"
  exit 0
fi
echo "FAIL: group:default/rogue-admins is accepted; Group must be allowed only for the organization file"
exit 1
