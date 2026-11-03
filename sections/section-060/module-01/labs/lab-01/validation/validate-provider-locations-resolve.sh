#!/usr/bin/env bash
# Check: The provider produces at least three locations and every one of them is found
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '[.locations[] | select(.origin == "provider:github:starfleetServices")] as $p | ($p | length) >= 3 and all($p[]; .status == "ok")' >/dev/null 2>&1; then
  echo "PASS: The provider produces at least three locations and every one of them is found"
  exit 0
fi
echo "FAIL: the provider has fewer than three locations, or some of its locations are not found"
exit 1
