#!/usr/bin/env bash
# Check: The provider runs no more often than every 15 minutes and has a timeout
set -uo pipefail

report="$(kubectl -n catalog-source get configmap -o json | kubectl -n catalog-tools exec -i deploy/catalog-tools -- node /opt/check/inspect.js 2>/dev/null)"
if ! echo "$report" | jq -e '.summary' >/dev/null 2>&1; then
  echo "FAIL: the catalog inspector did not return a report (is the catalog-tools pod Ready?)"
  exit 1
fi

if echo "$report" | jq -e '.config.providers.github.starfleetServices.schedule as $s | ($s.timeout != null) and ((($s.frequency.hours // 0) * 60 + ($s.frequency.minutes // 0) + (($s.frequency.seconds // 0) / 60)) >= 15)' >/dev/null 2>&1; then
  echo "PASS: The provider runs no more often than every 15 minutes and has a timeout"
  exit 0
fi
echo "FAIL: the schedule has no timeout, or the frequency is shorter than 15 minutes"
exit 1
