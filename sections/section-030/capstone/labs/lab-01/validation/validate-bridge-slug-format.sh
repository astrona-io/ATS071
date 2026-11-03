#!/usr/bin/env bash
# Check: The bridge project slug uses the owner/repository format
set -uo pipefail
fail=0

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi


if ! echo "$report" | jq -e '.entities[] | select(.ref == "component:default/bridge" and .ingested == true) | select(.metadata.annotations["github.com/project-slug"] == "starfleet-org/bridge")' >/dev/null; then
  echo "FAIL: bridge must be ingested with github.com/project-slug set to the owner/repository form of its repository"
  fail=1
fi
if [ "$fail" -eq 0 ]; then echo "PASS: The bridge project slug uses the owner/repository format"; fi
exit "$fail"
