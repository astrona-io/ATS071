#!/usr/bin/env bash
# Check: The bridge Component carries techdocs-ref as an annotation
set -uo pipefail
fail=0

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi


if ! echo "$report" | jq -e '.entities[] | select(.ref == "component:default/bridge" and .ingested == true)' >/dev/null; then
  echo "FAIL: component:default/bridge is not ingested; errors: $(echo "$report" | jq -c '[.errors[].message[0:120]]')"
  fail=1
fi
if [ "$fail" -eq 0 ] && ! echo "$report" | jq -e '.entities[] | select(.ref == "component:default/bridge") | select(.metadata.annotations["backstage.io/techdocs-ref"] == "dir:.") | select((.metadata.labels // {}) | has("backstage.io/techdocs-ref") | not)' >/dev/null; then
  echo "FAIL: bridge must have the annotation backstage.io/techdocs-ref with the value dir:. and no label with that key"
  fail=1
fi
if [ "$fail" -eq 0 ]; then echo "PASS: The bridge Component carries techdocs-ref as an annotation"; fi
exit "$fail"
