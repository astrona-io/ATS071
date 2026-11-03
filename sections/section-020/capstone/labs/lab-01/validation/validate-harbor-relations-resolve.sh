#!/usr/bin/env bash
# Check: harbor-control is accepted and its owner and system resolve
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '(.entities[] | select(.ref == "component:default/harbor-control" and .ingested == true)) and ([.unresolved[] | select(.from == "component:default/harbor-control")] | length == 0)' >/dev/null 2>&1; then
  echo "PASS: harbor-control is accepted and its owner and system resolve"
  exit 0
fi
echo "FAIL: harbor-control is not accepted or one of its relations does not resolve"
exit 1
