#!/usr/bin/env bash
# Check: No repository was removed and the Component and API kinds are still allowed
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '(.repos | length == 4) and (.config.rules | length > 0) and (.config.rules | map(.allow[]) | (index("Component") != null and index("API") != null)) and (.config.locations | length >= 3) and (all(.locations[]; .status == "ok"))' >/dev/null 2>&1; then
  echo "PASS: No repository was removed and the Component and API kinds are still allowed"
  exit 0
fi
echo "FAIL: a repository is missing, Component or API is no longer allowed, or a location cannot be read"
exit 1
