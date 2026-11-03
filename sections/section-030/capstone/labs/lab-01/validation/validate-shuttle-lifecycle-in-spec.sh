#!/usr/bin/env bash
# Check: The shuttle lifecycle is a spec field, not an annotation
set -uo pipefail
fail=0

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi


if ! echo "$report" | jq -e '.entities[] | select(.ref == "component:default/shuttle" and .ingested == true) | select(.spec.lifecycle == "production") | select(.metadata.annotations | has("example.com/lifecycle") | not)' >/dev/null; then
  echo "FAIL: shuttle must be ingested with spec.lifecycle set to production and without an example.com/lifecycle annotation"
  fail=1
fi
if [ "$fail" -eq 0 ]; then echo "PASS: The shuttle lifecycle is a spec field, not an annotation"; fi
exit "$fail"
