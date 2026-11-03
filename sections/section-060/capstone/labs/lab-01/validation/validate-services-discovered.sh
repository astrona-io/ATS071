#!/usr/bin/env bash
# Check: bridge, scout and shuttle are found by the provider and ingested
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '[.locations[] | select(.origin == "provider:github:starfleetServices" and .status == "ok") | .target] as $t | all(["bridge", "scout", "shuttle"][]; . as $n | any($t[]; contains("/" + $n + "/"))) and (.summary.ingested | (index("component:default/bridge") != null) and (index("component:default/scout") != null) and (index("component:default/shuttle") != null))' >/dev/null 2>&1; then
  echo "PASS: bridge, scout and shuttle are found by the provider and ingested"
  exit 0
fi
echo "FAIL: the provider did not discover and ingest bridge, scout and shuttle"
exit 1
