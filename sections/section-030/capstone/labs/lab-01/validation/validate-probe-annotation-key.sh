#!/usr/bin/env bash
# Check: The probe Component is ingested and keeps its on-call link under a valid key
set -uo pipefail
fail=0

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi


if ! echo "$report" | jq -e '.entities[] | select(.ref == "component:default/probe" and .ingested == true) | select(.metadata.annotations | to_entries | any(.value == "https://oncall.starfleet.example/probe"))' >/dev/null; then
  echo "FAIL: component:default/probe is not ingested with the on-call link kept as an annotation value; errors: $(echo "$report" | jq -c '[.errors[].message[0:100]]')"
  fail=1
fi
if [ "$fail" -eq 0 ]; then echo "PASS: The probe Component is ingested and keeps its on-call link under a valid key"; fi
exit "$fail"
