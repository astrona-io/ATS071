#!/usr/bin/env bash
# Check: The shuttle Component is ingested and keeps its pager annotation as a string
set -uo pipefail
fail=0

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi


if ! echo "$report" | jq -e '.entities[] | select(.ref == "component:default/shuttle" and .ingested == true)' >/dev/null; then
  echo "FAIL: component:default/shuttle is not ingested; errors: $(echo "$report" | jq -c '[.errors[].message[0:120]]')"
  fail=1
fi
if [ "$fail" -eq 0 ] && ! echo "$report" | jq -e '.entities[] | select(.ref == "component:default/shuttle") | select(.metadata.annotations["example.com/pager-enabled"] == "true")' >/dev/null; then
  echo "FAIL: shuttle must keep the annotation example.com/pager-enabled with the string value true"
  fail=1
fi
if [ "$fail" -eq 0 ]; then echo "PASS: The shuttle Component is ingested and keeps its pager annotation as a string"; fi
exit "$fail"
