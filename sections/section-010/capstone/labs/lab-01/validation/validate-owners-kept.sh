#!/usr/bin/env bash
# Check: The three repositories, both teams and the owner of berth-board are unchanged
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '(.repos | length) == 3 and ([.entities[] | select(.ingested == true and (.ref == "group:default/yard-ops" or .ref == "group:default/berth-team"))] | length) == 2 and ([.entities[] | select(.ref == "component:default/berth-board" and .spec.owner == "berth-team")] | length) == 1' >/dev/null 2>&1; then
  echo "PASS: The three repositories, both teams and the owner of berth-board are unchanged"
  exit 0
fi
echo "FAIL: a repository or a team was removed, or the owner of berth-board changed"
exit 1
