#!/usr/bin/env bash
# Check: Each entity reference is declared by exactly one location
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
if ! echo "$report" | jq -e '.entities[] | select((.location | contains("/shuttle/")) and .kind == "Component" and .ingested == true)' >/dev/null; then
  echo "FAIL: no Component from the shuttle repository is ingested"
  fail=1
fi
if ! echo "$report" | jq -e '.entities[] | select(.ref == "component:default/bridge" and .ingested == true and (.location | contains("/bridge/")))' >/dev/null; then
  echo "FAIL: component:default/bridge must stay ingested from the bridge repository"
  fail=1
fi

if [ "$fail" -eq 0 ]; then echo "PASS: Each entity reference is declared by exactly one location"; fi
exit "$fail"
