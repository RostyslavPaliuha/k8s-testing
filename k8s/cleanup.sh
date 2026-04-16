#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🧹 Cleaning up Kubernetes resources..."

echo ""
echo "🗑️  Cleaning up service resources..."
kubectl delete -f "$SCRIPT_DIR/ingress.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/ingress-controller.yml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/hpa.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/service.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/deployment.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/configmap.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/namespace.yaml" --ignore-not-found

echo ""
echo "🗑️  Cleaning up authorization-server resources..."
kubectl delete -f "$SCRIPT_DIR/authorization-server/service.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/authorization-server/deployment.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/authorization-server/secret.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/authorization-server/configmap.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/authorization-server/namespace.yaml" --ignore-not-found

echo ""
echo "🗑️  Cleaning up ingress-gateway resources..."
kubectl delete -f "$SCRIPT_DIR/ingress-gateway/service.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/ingress-gateway/deployment.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/ingress-gateway/secret.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/ingress-gateway/configmap.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/ingress-gateway/namespace.yaml" --ignore-not-found

echo ""
echo "🗑️  Cleaning up ArgoCD resources..."
kubectl delete -f "$SCRIPT_DIR/argocd/argocd_service_definition.yml" --ignore-not-found
kubectl delete namespace argocd --ignore-not-found

echo ""
echo "🗑️  Cleaning up ingress-nginx controller..."
kubectl delete -f "$SCRIPT_DIR/ingress-controller.yml" --ignore-not-found

echo ""
echo "🗑️  Cleaning up Metrics Server..."
kubectl delete -f "https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.2/components.yaml" --ignore-not-found

echo ""
echo "✅ Cleanup complete!"
