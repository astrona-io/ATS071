#!/usr/bin/env bash
# Starting state. Environment only: starts the catalog tools and creates the
# descriptor repositories with the faults the task describes.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/tools.yaml"
kubectl -n catalog-tools create configmap inspect-script --from-file=inspect.js="$DIR/tools/inspect.js" --dry-run=client -o yaml | kubectl apply -f -
kubectl -n catalog-tools rollout status deployment/catalog-tools --timeout=300s
kubectl apply -f "$DIR/manifests/lab-start.yaml"
echo "[lab] Ready."
