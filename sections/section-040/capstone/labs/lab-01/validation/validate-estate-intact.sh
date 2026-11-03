#!/usr/bin/env bash
# Check: Every repository still exists, the outpost location is kept and no relation is unresolved
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '(. as $r | ["registry","outpost","sensors"] | all(. as $n | $r.repos | index($n) != null)) and ([.config.locations[] | select(.target | test("outpost/blob/main/catalog-info.yaml"))] | length) == 1 and (.unresolved | length) == 0' >/dev/null 2>&1; then
  echo "PASS: Every repository still exists, the outpost location is kept and no relation is unresolved"
  exit 0
fi
echo "FAIL: a repository or the outpost location is missing, or a relation does not resolve"
exit 1
