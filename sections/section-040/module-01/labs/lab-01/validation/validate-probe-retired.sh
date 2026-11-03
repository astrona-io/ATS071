#!/usr/bin/env bash
# Check: The probe is no longer registered and its repository still exists
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '([.entities[] | select(.ref == "component:default/probe")] | length) == 0 and (.repos | index("legacy-probe") != null)' >/dev/null 2>&1; then
  echo "PASS: The probe is no longer registered and its repository still exists"
  exit 0
fi
echo "FAIL: component:default/probe is still in the catalog, or the repo-legacy-probe ConfigMap was deleted"
exit 1
