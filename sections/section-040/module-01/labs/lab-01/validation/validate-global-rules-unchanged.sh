#!/usr/bin/env bash
# Check: The global catalog rules were not widened
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '(.config.rules == null) and (([.config.locations[] | select(.target | test("starfleet-org")) | .rules // []] | flatten | length) > 0)' >/dev/null 2>&1; then
  echo "PASS: The global catalog rules were not widened"
  exit 0
fi
echo "FAIL: catalog.rules was added, or the organization location has no rules of its own"
exit 1
