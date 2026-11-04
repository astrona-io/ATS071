#!/usr/bin/env bash
# Check: Nothing was deleted and the correct entries were kept (guard)
set -uo pipefail
fail=0

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

for repo in starfleet-org bridge scout shuttle probe cargo-hauler; do
  if ! echo "$report" | jq -e --arg r "$repo" '.repos | index($r) != null' >/dev/null; then
    echo "FAIL: the repository ConfigMap repo-$repo is missing"
    fail=1
  fi
done
if ! echo "$report" | jq -e '[.entities[] | select(.ingested == true) | .ref] | contains(["component:default/bridge","component:default/scout","component:default/probe"])' >/dev/null; then
  echo "FAIL: bridge, scout and probe must stay ingested"
  fail=1
fi
if ! echo "$report" | jq -e '.entities[] | select(.ref == "component:default/shuttle") | any(.relations[]; .type == "dependsOn" and .target == "component:default/probe")' >/dev/null; then
  echo "FAIL: shuttle must keep its dependsOn relation to probe"
  fail=1
fi
if [ "$fail" -eq 0 ]; then echo "PASS: Nothing was deleted and the correct entries were kept (guard)"; fi
exit "$fail"
