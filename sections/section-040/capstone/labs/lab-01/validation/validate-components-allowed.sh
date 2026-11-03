#!/usr/bin/env bash
# Check: The components of the services file are ingested and Component is still allowed
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '[.entities[] | select(.ingested == true) | .ref] as $ok | (["component:default/helm","component:default/outpost-relay"] | all(. as $r | $ok | index($r)))' >/dev/null 2>&1; then
  echo "PASS: The components of the services file are ingested and Component is still allowed"
  exit 0
fi
echo "FAIL: helm or outpost-relay is not ingested, check the stage rules in the errors"
exit 1
