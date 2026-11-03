#!/usr/bin/env bash
# Check: The teams from the crew directory are ingested and every owner resolves
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '(.summary.ingested | (index("group:default/starfleet-ops") != null) and (index("group:default/scout-team") != null)) and ((.unresolved | length) == 0)' >/dev/null 2>&1; then
  echo "PASS: The teams from the crew directory are ingested and every owner resolves"
  exit 0
fi
echo "FAIL: the Group entities are not ingested or some owner relations do not resolve"
exit 1
