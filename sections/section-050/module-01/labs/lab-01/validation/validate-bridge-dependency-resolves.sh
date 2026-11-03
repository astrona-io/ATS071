#!/usr/bin/env bash
# Check: The bridge dependency on telemetry-db is ingested and resolves
set -uo pipefail
fail=0

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi


if ! echo "$report" | jq -e '.entities[] | select(.ref == "resource:default/telemetry-db" and .ingested == true)' >/dev/null; then
  echo "FAIL: resource:default/telemetry-db is not ingested; errors: $(echo "$report" | jq -c '[.errors[] | select(.entity == "resource:default/telemetry-db") | .message]')"
  fail=1
fi
if [ "$fail" -eq 0 ] && echo "$report" | jq -e '.unresolved[] | select(.from == "component:default/bridge")' >/dev/null; then
  echo "FAIL: a relation of component:default/bridge still points at an entity that is not ingested"
  fail=1
fi

if [ "$fail" -eq 0 ]; then echo "PASS: The bridge dependency on telemetry-db is ingested and resolves"; fi
exit "$fail"
