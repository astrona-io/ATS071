#!/usr/bin/env bash
# Check: The service file listed by the ops Location is read and ops-gateway is accepted
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '(.locations[] | select(.target == "https://git.starfleet.example/ops/blob/main/services.yaml" and .status == "ok")) and (.entities[] | select(.ref == "component:default/ops-gateway" and .ingested == true))' >/dev/null 2>&1; then
  echo "PASS: The service file listed by the ops Location is read and ops-gateway is accepted"
  exit 0
fi
echo "FAIL: component:default/ops-gateway is not ingested"
exit 1
