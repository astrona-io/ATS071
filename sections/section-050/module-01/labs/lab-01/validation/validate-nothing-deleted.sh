#!/usr/bin/env bash
# Check: All repositories and the organization entities are still in place
set -uo pipefail
fail=0

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi


for repo in starfleet-org bridge scout probe drifter shuttle; do
  if ! echo "$report" | jq -e --arg r "$repo" '.repos | index($r)' >/dev/null; then
    echo "FAIL: the repository repo-$repo was deleted"
    fail=1
  fi
done
for ref in group:default/starfleet-ops group:default/scout-team user:default/kira component:default/bridge; do
  if ! echo "$report" | jq -e --arg r "$ref" '.entities[] | select(.ref == $r and .ingested == true)' >/dev/null; then
    echo "FAIL: $ref is not ingested"
    fail=1
  fi
done
if ! echo "$report" | jq -e '.configError == null' >/dev/null; then
  echo "FAIL: the catalog configuration does not parse"
  fail=1
fi

if [ "$fail" -eq 0 ]; then echo "PASS: All repositories and the organization entities are still in place"; fi
exit "$fail"
