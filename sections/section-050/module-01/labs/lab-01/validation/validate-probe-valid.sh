#!/usr/bin/env bash
# Check: The probe descriptor passes entity validation and is ingested
set -uo pipefail
fail=0

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi


if ! echo "$report" | jq -e '.entities[] | select((.location | contains("/probe/")) and .kind == "Component" and .ingested == true)' >/dev/null; then
  echo "FAIL: no Component from the probe repository is ingested; errors: $(echo "$report" | jq -c '[.errors[] | select(.location | contains("/probe/")) | .message]')"
  fail=1
fi

if [ "$fail" -eq 0 ]; then echo "PASS: The probe descriptor passes entity validation and is ingested"; fi
exit "$fail"
