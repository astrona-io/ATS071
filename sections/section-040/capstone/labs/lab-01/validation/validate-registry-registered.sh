#!/usr/bin/env bash
# Check: The root Location of the registry repository is registered and read
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '([.config.locations[] | select(.target | test("registry/blob/main/catalog-info.yaml"))] | length) == 1 and ([.locations[] | select(.target | test("registry/blob/main/catalog-info.yaml")) | select(.status == "ok")] | length) == 1' >/dev/null 2>&1; then
  echo "PASS: The root Location of the registry repository is registered and read"
  exit 0
fi
echo "FAIL: the registry root file is not registered in catalog.locations, or it cannot be read"
exit 1
