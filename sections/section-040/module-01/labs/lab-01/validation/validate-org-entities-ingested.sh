#!/usr/bin/env bash
# Check: The groups and the user of the organization file are ingested
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '[.entities[] | select(.ingested == true) | .ref] as $ok | (["group:default/starfleet-ops","group:default/fleet-team","group:default/scout-team","user:default/kira"] | all(. as $r | $ok | index($r)))' >/dev/null 2>&1; then
  echo "PASS: The groups and the user of the organization file are ingested"
  exit 0
fi
echo "FAIL: the groups or the user of the organization file are not ingested"
exit 1
