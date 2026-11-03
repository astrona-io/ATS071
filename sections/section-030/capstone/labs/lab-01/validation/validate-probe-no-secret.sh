#!/usr/bin/env bash
# Check: No annotation on the probe Component holds a password
set -uo pipefail
fail=0

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi


if ! echo "$report" | jq -e '.entities[] | select(.ref == "component:default/probe" and .ingested == true)' >/dev/null; then
  echo "FAIL: component:default/probe is not ingested, so the annotations cannot be checked"
  fail=1
elif echo "$report" | jq -e '.entities[] | select(.ref == "component:default/probe") | (.metadata.annotations | to_entries[] | select((.key | test("token|secret|password"; "i")) or (.value | tostring | test("hunter2"))))' >/dev/null; then
  echo "FAIL: an annotation on probe still looks like a credential"
  fail=1
fi
if [ "$fail" -eq 0 ]; then echo "PASS: No annotation on the probe Component holds a password"; fi
exit "$fail"
