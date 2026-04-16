#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

delete_namespace() {
  local namespace="$1"

  kubectl delete namespace "$namespace" --ignore-not-found --wait=false

  if kubectl get namespace "$namespace" >/dev/null 2>&1; then
    echo "⏳ Waiting for namespace $namespace to terminate..."
    if ! kubectl wait --for=delete "namespace/$namespace" --timeout=120s; then
      echo "⚠️  Namespace $namespace is still terminating. Continuing cleanup."
    fi
  fi
}

echo "🧹 Cleaning up Kubernetes resources..."

echo ""
echo "🗑️  Cleaning up ArgoCD resources..."
kubectl delete -f "$SCRIPT_DIR/argocd/argo-application-authorization-server.yml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/argocd/argo-application-ingress-gateway.yml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/argocd/argo-application-resource-server.yml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/cluster-components/ingress-controller.yml" --ignore-not-found

echo ""
echo "🗑️  Cleaning up application namespaces..."
delete_namespace service-ns
delete_namespace authorization-server-ns
delete_namespace ingress-gateway-ns
delete_namespace ingress-nginx

echo ""
echo "🗑️  Cleaning up stale ingress-nginx cluster-scoped resources..."
kubectl delete validatingwebhookconfiguration ingress-nginx-admission --ignore-not-found
kubectl delete ingressclass nginx --ignore-not-found
kubectl delete clusterrole ingress-nginx --ignore-not-found
kubectl delete clusterrolebinding ingress-nginx --ignore-not-found
kubectl delete clusterrole ingress-nginx-admission --ignore-not-found
kubectl delete clusterrolebinding ingress-nginx-admission --ignore-not-found

echo ""
echo "🗑️  Cleaning up ArgoCD namespace..."
delete_namespace argocd

echo ""
echo "🗑️  Cleaning up Metrics Server..."
kubectl delete -f "https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.2/components.yaml" --ignore-not-found

echo ""
echo "✅ Cleanup complete!"
