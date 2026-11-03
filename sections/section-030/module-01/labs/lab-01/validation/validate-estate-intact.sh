#!/usr/bin/env bash
# Check: Nothing was deleted and the correct annotations were kept (guard)
set -uo pipefail
fail=0

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi


for repo in starfleet-org bridge scout shuttle; do
  if ! echo "$report" | jq -e --arg r "$repo" '.repos | index($r) != null' >/dev/null; then
    echo "FAIL: the repository ConfigMap repo-$repo is missing"
    fail=1
  fi
done
if ! echo "$report" | jq -e '[.entities[] | select(.ingested == true) | .ref] | contains(["group:default/starfleet-ops","group:default/scout-team"])' >/dev/null; then
  echo "FAIL: the Groups starfleet-ops and scout-team must still be ingested"
  fail=1
fi
if ! echo "$report" | jq -e '([.entities[] | select(.ref == "component:default/bridge") | .metadata.annotations["github.com/project-slug"]] | all(. == "starfleet-org/bridge")) and ([.entities[] | select(.ref == "component:default/shuttle") | .metadata.annotations["github.com/project-slug"]] | all(. == "starfleet-org/shuttle"))' >/dev/null; then
  echo "FAIL: the project slugs of bridge and shuttle were correct and must not change"
  fail=1
fi

if [ "$fail" -eq 0 ]; then echo "PASS: Nothing was deleted and the correct annotations were kept (guard)"; fi
exit "$fail"
