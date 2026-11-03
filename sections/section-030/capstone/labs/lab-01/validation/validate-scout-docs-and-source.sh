#!/usr/bin/env bash
# Check: The scout Component declares its TechDocs source and a source location
set -uo pipefail
fail=0

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi


if ! echo "$report" | jq -e '.entities[] | select(.ref == "component:default/scout" and .ingested == true) | select(.metadata.annotations["backstage.io/techdocs-ref"] == "dir:." and .metadata.annotations["backstage.io/source-location"] == "url:https://git.starfleet.example/scout/tree/main/")' >/dev/null; then
  echo "FAIL: scout needs backstage.io/techdocs-ref dir:. and backstage.io/source-location in location-reference form for its own repository"
  fail=1
fi
if [ "$fail" -eq 0 ]; then echo "PASS: The scout Component declares its TechDocs source and a source location"; fi
exit "$fail"
