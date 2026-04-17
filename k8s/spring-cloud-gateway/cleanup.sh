#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🧹 Cleaning up ingress-gateway resources..."

kubectl delete -f "$SCRIPT_DIR/ingress.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/service.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/deployment.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/secret.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/configmap.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/namespace.yaml" --ignore-not-found

echo "✅ Ingress-gateway cleanup complete!"
