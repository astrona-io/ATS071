#!/usr/bin/env bash
# Check: The provider keeps its organization and branch filter and all eight repositories still exist
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '(.config.providers.github.starfleetServices.organization == "starfleet") and (.config.providers.github.starfleetServices.filters.branch == "main") and (.repos | length == 8)' >/dev/null 2>&1; then
  echo "PASS: The provider keeps its organization and branch filter and all eight repositories still exist"
  exit 0
fi
echo "FAIL: the provider organization or the branch filter changed, or a repository is missing"
exit 1
