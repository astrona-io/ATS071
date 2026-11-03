#!/usr/bin/env bash
# Starts the catalog tools and the Starfleet descriptor repositories.
# Environment only: nothing here is graded.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/tools.yaml"
kubectl -n catalog-tools create configmap inspect-script --from-file=inspect.js="$DIR/tools/inspect.js" --dry-run=client -o yaml | kubectl apply -f -
kubectl -n catalog-tools rollout status deployment/catalog-tools --timeout=300s
kubectl apply -f "$DIR/manifests/starfleet.yaml"
echo "[playground] Ready."
