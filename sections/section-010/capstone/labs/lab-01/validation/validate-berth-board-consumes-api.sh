#!/usr/bin/env bash
# Check: The berth-board Component consumes gate-api and the relation resolves
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '([.entities[] | select(.ref == "component:default/berth-board" and .ingested == true) | .relations[] | select(.type == "consumesApi" and .target == "api:default/gate-api")] | length) == 1 and ([.unresolved[] | select(.from == "component:default/berth-board")] | length) == 0' >/dev/null 2>&1; then
  echo "PASS: The berth-board Component consumes gate-api and the relation resolves"
  exit 0
fi
echo "FAIL: berth-board does not have a resolved consumesApi relation to api:default/gate-api"
exit 1
