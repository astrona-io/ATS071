#!/usr/bin/env bash
# Check: The beacon Component is ingested and its relations resolve
set -uo pipefail
fail=0

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if ! echo "$report" | jq -e '.entities[] | select(.ref == "component:default/beacon" and .ingested == true)' >/dev/null; then
  echo "FAIL: component:default/beacon is not ingested; errors: $(echo "$report" | jq -c '[.errors[] | select(.entity == "component:default/beacon") | .message[0:160]]')"
  fail=1
fi
if [ "$fail" -eq 0 ] && echo "$report" | jq -e '.unresolved[] | select(.from == "component:default/beacon")' >/dev/null; then
  echo "FAIL: a relation of component:default/beacon points at an entity that is not ingested"
  fail=1
fi
if [ "$fail" -eq 0 ]; then echo "PASS: The beacon Component is ingested and its relations resolve"; fi
exit "$fail"
