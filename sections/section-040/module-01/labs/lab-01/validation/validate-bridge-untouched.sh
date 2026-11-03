#!/usr/bin/env bash
# Check: The bridge Component is still ingested and no repository was deleted
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '([.entities[] | select(.ref == "component:default/bridge" and .ingested == true)] | length) == 1 and (. as $r | ["bridge","scout","starfleet-org","fleet-registry","legacy-probe"] | all(. as $n | $r.repos | index($n) != null))' >/dev/null 2>&1; then
  echo "PASS: The bridge Component is still ingested and no repository was deleted"
  exit 0
fi
echo "FAIL: bridge is not ingested or a repository ConfigMap is missing"
exit 1
