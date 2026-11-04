#!/usr/bin/env bash
# Check: The cargo-hauler owner is a Group that exists
set -uo pipefail
fail=0

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if ! echo "$report" | jq -e '.entities[] | select(.ref == "component:default/cargo-hauler" and .ingested == true) | select(any(.relations[]; .type == "ownedBy" and .target == "group:default/starfleet-ops"))' >/dev/null; then
  echo "FAIL: cargo-hauler must be ingested and owned by group:default/starfleet-ops"
  fail=1
fi
if [ "$(echo "$report" | jq '.unresolved | length')" -ne 0 ]; then
  echo "FAIL: unresolved relations remain: $(echo "$report" | jq -c '.unresolved')"
  fail=1
fi
if [ "$fail" -eq 0 ]; then echo "PASS: The cargo-hauler owner is a Group that exists"; fi
exit "$fail"
