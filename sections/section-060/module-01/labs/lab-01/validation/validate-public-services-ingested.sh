#!/usr/bin/env bash
# Check: The public repositories scout and shuttle are ingested through the provider
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '.summary.ingested | (index("component:default/scout") != null) and (index("component:default/shuttle") != null)' >/dev/null 2>&1; then
  echo "PASS: The public repositories scout and shuttle are ingested through the provider"
  exit 0
fi
echo "FAIL: component:default/scout and component:default/shuttle are not both ingested"
exit 1
