#!/usr/bin/env bash
# Check: Nothing was deleted, the three repositories and the owners are still in place
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '(.repos | length) == 3 and ([.entities[] | select(.ingested == true and (.ref == "group:default/starfleet-ops" or .ref == "group:default/scout-team" or .ref == "component:default/scout" or .ref == "system:default/navigation"))] | length) == 4 and ([.entities[] | select(.ref == "component:default/bridge" and .spec.system == "navigation")] | length) == 1' >/dev/null 2>&1; then
  echo "PASS: Nothing was deleted, the three repositories and the owners are still in place"
  exit 0
fi
echo "FAIL: a repository or an entity was removed or its system was changed"
exit 1
