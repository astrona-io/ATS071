#!/usr/bin/env bash
# Check: No repository or location was removed and the rules were not changed
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '(.repos | length == 6) and (.locations | length == 6) and (all(.locations[]; .status == "ok")) and (.config.rules == null) and (.entities[] | select(.ref == "component:default/scout" and .ingested == true))' >/dev/null 2>&1; then
  echo "PASS: No repository or location was removed and the rules were not changed"
  exit 0
fi
echo "FAIL: a repository or location is missing, a location is not readable, rules were added or scout is not ingested"
exit 1
