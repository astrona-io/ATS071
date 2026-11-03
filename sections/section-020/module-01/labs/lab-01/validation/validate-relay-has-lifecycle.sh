#!/usr/bin/env bash
# Check: The relay Component is accepted with lifecycle production
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '.entities[] | select(.ref == "component:default/relay" and .ingested == true and .spec.lifecycle == "production")' >/dev/null 2>&1; then
  echo "PASS: The relay Component is accepted with lifecycle production"
  exit 0
fi
echo "FAIL: component:default/relay is not ingested with lifecycle production"
exit 1
