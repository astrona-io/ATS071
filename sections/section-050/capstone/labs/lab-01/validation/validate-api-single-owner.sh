#!/usr/bin/env bash
# Check: Every API reference has one location and relay keeps its own API
set -uo pipefail
fail=0

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if ! echo "$report" | jq -e '(.conflicts | length) == 0' >/dev/null; then
  echo "FAIL: conflicts remain: $(echo "$report" | jq -c '.conflicts')"
  fail=1
fi
if ! echo "$report" | jq -e '.entities[] | select(.kind == "API" and .ingested == true and (.location | contains("/relay/")))' >/dev/null; then
  echo "FAIL: no API from the relay repository is ingested"
  fail=1
fi
if ! echo "$report" | jq -e '.entities[] | select(.ref == "api:default/beacon-api" and .ingested == true and (.location | contains("/beacon/")))' >/dev/null; then
  echo "FAIL: api:default/beacon-api must stay with the beacon repository"
  fail=1
fi
if [ "$fail" -eq 0 ] && echo "$report" | jq -e '.unresolved[] | select(.from == "component:default/relay")' >/dev/null; then
  echo "FAIL: a relation of component:default/relay points at an entity that is not ingested"
  fail=1
fi
if [ "$fail" -eq 0 ]; then echo "PASS: Every API reference has one location and relay keeps its own API"; fi
exit "$fail"
