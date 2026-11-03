#!/usr/bin/env bash
# Check: The provider keeps its organization and branch scope and the descriptor repositories still exist
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '(.config.providers.github.starfleetServices.organization == "starfleet") and (.repos | length == 8) and (.summary.ingested | (index("group:default/starfleet-ops") != null) and (index("component:default/hangar-legacy") == null) and (index("component:default/outpost-relay") == null)) and ([.config.locations[]? | select(.target | test("catalog-info"))] | length == 0)' >/dev/null 2>&1; then
  echo "PASS: The provider keeps its organization and branch scope and the descriptor repositories still exist"
  exit 0
fi
echo "FAIL: the provider organization changed, a repository outside the scope is ingested, a repository is missing or a static location was added for a service"
exit 1
