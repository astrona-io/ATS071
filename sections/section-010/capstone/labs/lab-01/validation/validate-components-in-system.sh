#!/usr/bin/env bash
# Check: The Components gate and berth-board are both part of the System shipyard
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '([.entities[] | select((.ref == "component:default/gate" or .ref == "component:default/berth-board") and .ingested == true) | .relations[] | select(.type == "partOf" and .target == "system:default/shipyard")] | length) == 2' >/dev/null 2>&1; then
  echo "PASS: The Components gate and berth-board are both part of the System shipyard"
  exit 0
fi
echo "FAIL: gate and berth-board are not both part of system:default/shipyard"
exit 1
