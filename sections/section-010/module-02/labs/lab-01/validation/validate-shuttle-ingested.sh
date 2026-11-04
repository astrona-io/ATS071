#!/usr/bin/env bash
# Check: The shuttle Component is ingested with the lifecycle production
set -uo pipefail
fail=0

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if ! echo "$report" | jq -e '.entities[] | select(.ref == "component:default/shuttle" and .ingested == true) | select(.spec.lifecycle == "production")' >/dev/null; then
  echo "FAIL: component:default/shuttle must be ingested with lifecycle production; errors: $(echo "$report" | jq -c '[.errors[].message[0:120]]')"
  fail=1
fi
if [ "$fail" -eq 0 ]; then echo "PASS: The shuttle Component is ingested with the lifecycle production"; fi
exit "$fail"
