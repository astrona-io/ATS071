#!/usr/bin/env bash
# Check: scout is claimed once, by the provider location
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '((.conflicts | length) == 0) and ([.entities[] | select(.ref == "component:default/scout" and .ingested == true) | .metadata.annotations["backstage.io/managed-by-location"]] | any(endswith("/scout/blob/main/catalog-info.yaml")))' >/dev/null 2>&1; then
  echo "PASS: scout is claimed once, by the provider location"
  exit 0
fi
echo "FAIL: there is a conflict, or scout was not read from catalog-info.yaml"
exit 1
