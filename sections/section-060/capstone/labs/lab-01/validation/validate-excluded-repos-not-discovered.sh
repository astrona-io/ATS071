#!/usr/bin/env bash
# Check: vault, sandbox-test, deprecated-relay and hangar-legacy are not ingested
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '.summary.ingested | (index("component:default/bridge") != null) and (index("component:default/vault") == null) and (index("component:default/sandbox-test") == null) and (index("component:default/deprecated-relay") == null) and (index("component:default/hangar-legacy") == null)' >/dev/null 2>&1; then
  echo "PASS: vault, sandbox-test, deprecated-relay and hangar-legacy are not ingested"
  exit 0
fi
echo "FAIL: a repository that must be excluded is ingested, or bridge is not ingested"
exit 1
