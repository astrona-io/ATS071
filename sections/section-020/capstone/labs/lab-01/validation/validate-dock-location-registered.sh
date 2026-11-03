#!/usr/bin/env bash
# Check: The dock repository is a configured location that can be read
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '.locations[] | select(.target == "https://git.starfleet.example/dock/blob/main/catalog-info.yaml" and .origin == "config" and .status == "ok")' >/dev/null 2>&1; then
  echo "PASS: The dock repository is a configured location that can be read"
  exit 0
fi
echo "FAIL: the dock descriptor file is not registered in catalog.locations"
exit 1
