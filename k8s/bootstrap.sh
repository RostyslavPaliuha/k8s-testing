#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
METRICS_VERSION="v0.7.2"

wait_for_rollout() {
  local resource="$1"
  local namespace="$2"
  local timeout="${3:-300s}"

  echo "   Waiting for ${resource} in namespace ${namespace}..."
  kubectl rollout status "${resource}" -n "${namespace}" --timeout="${timeout}"
}

wait_for_ingress_nginx() {
  local attempts=60

  echo "   Waiting for ingress-nginx admission service..."
  for ((i=1; i<=attempts; i++)); do
    if kubectl get svc ingress-nginx-controller-admission -n ingress-nginx &>/dev/null; then
      echo "✅ ingress-nginx admission service is present"
      wait_for_rollout deployment/ingress-nginx-controller ingress-nginx 300s
      return 0
    fi
    sleep 5
  done

  echo "❌ ingress-nginx controller was not ready in time"
  return 1
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Kubernetes Cluster Bootstrap"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Verify cluster is reachable ──────────────────────────────────
echo ""
echo "📡 Checking cluster connectivity..."
if ! kubectl cluster-info &>/dev/null; then
  echo "❌ Cannot reach Kubernetes API. Is the cluster running?"
  exit 1
fi
echo "✅ Cluster reachable"

# ── 1. Metrics Server ────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Step 1/4: Installing Metrics Server"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if kubectl get deployment metrics-server -n kube-system &>/dev/null; then
  echo "✅ Metrics Server already installed, skipping"
else
  echo "   Installing Metrics Server ${METRICS_VERSION}..."
  kubectl apply -f "https://github.com/kubernetes-sigs/metrics-server/releases/download/${METRICS_VERSION}/components.yaml"

  echo "   Patching for Docker Desktop (--kubelet-insecure-tls)..."
  kubectl patch deployment metrics-server -n kube-system \
    --type='json' \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

  echo "   Waiting for Metrics Server to be ready..."
  kubectl rollout status deployment metrics-server -n kube-system --timeout=120s

  # Verify metrics are flowing
  echo "   Waiting 30s for first metrics collection..."
  sleep 30
  if kubectl top nodes &>/dev/null; then
    echo "✅ Metrics Server running and collecting data"
  else
    echo "⚠️  Metrics Server is running but not yet reporting — will retry during verification"
  fi
fi



# ── 2. ArgoCD ────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🅰️  Step 2/4: Installing ArgoCD"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if kubectl get deployment argocd-server -n argocd &>/dev/null; then
  echo "✅ ArgoCD already installed, skipping"
else
  echo "   Creating argocd namespace..."
  kubectl create namespace argocd

  echo "   Installing ArgoCD manifests..."
  #TODO find out how to fix The CustomResourceDefinition "applicationsets.argoproj.io" is invalid: metadata.annotations: Too long: may not be more than 262144 bytes
  # Use --validate=false to skip validation for the problematic CRD
  # Note: The command may print validation warnings but should still succeed
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --validate=false || true

  # Verify that the core ArgoCD components were installed despite any validation warnings
  if ! kubectl get deployment argocd-server -n argocd &>/dev/null; then
    echo "❌ ArgoCD server deployment not found - installation may have failed"
    exit 1
  fi

  wait_for_rollout deployment/argocd-server argocd 300s
  wait_for_rollout deployment/argocd-repo-server argocd 300s
  wait_for_rollout statefulset/argocd-application-controller argocd 300s
  sleep 10
  PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
  echo "✅ ArgoCD installed"
  echo "   🔑 Admin password: $PASSWORD"
fi

echo "Apply the cluster components"
kubectl apply -f "$SCRIPT_DIR/cluster-components/ingress-controller.yml"
wait_for_ingress_nginx

echo "Apply argocd application definitions"
kubectl apply -f "$SCRIPT_DIR/argocd/argo-application-authorization-server.yml"
kubectl apply -f "$SCRIPT_DIR/argocd/argo-application-ingress-gateway.yml"
kubectl apply -f "$SCRIPT_DIR/argocd/argo-application-resource-server.yml"

ERRORS=0

echo ""
echo "   Metrics Server:"
if kubectl top nodes &>/dev/null; then
  echo "   ✅ Reporting node metrics"
else
  echo "   ❌ Not reporting metrics yet — wait 30s and try: kubectl top nodes"
  ERRORS=$((ERRORS + 1))
fi

echo ""
echo "   ArgoCD:"
if kubectl get deployment argocd-server -n argocd -o jsonpath='{.status.readyReplicas}' 2>/dev/null | grep -q "1"; then
  echo "   ✅ argocd-server ready"
else
  echo "   ❌ argocd-server not ready"
  ERRORS=$((ERRORS + 1))
fi

echo ""
echo "   ingress-nginx:"
if kubectl get deployment ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.readyReplicas}' 2>/dev/null | grep -q "1"; then
  echo "   ✅ ingress-nginx-controller ready"
else
  echo "   ❌ ingress-nginx-controller not ready"
  ERRORS=$((ERRORS + 1))
fi

echo ""
echo "   Resource Service:"
if kubectl get deployment service-deployment -n service-ns -o jsonpath='{.status.readyReplicas}' 2>/dev/null | grep -q "1"; then
  echo "   ✅ service-deployment ready"
else
  echo "   ❌ service-deployment not ready"
  ERRORS=$((ERRORS + 1))
fi

echo ""
echo "   Authorization Server Database:"
if kubectl get statefulset postgres-postgresql -n authorization-server-ns -o jsonpath='{.status.readyReplicas}' 2>/dev/null | grep -q "1"; then
  echo "   ✅ postgres-postgresql ready"
else
  echo "   ❌ postgres-postgresql not ready"
  ERRORS=$((ERRORS + 1))
fi

echo ""
echo "   HPA:"
sleep 5
HPA_STATUS=$(kubectl get hpa service-hpa -n service-ns -o custom-columns='TARGETS:.status.currentMetrics[0].resource.current' 2>/dev/null || echo "unknown")
if echo "$HPA_STATUS" | grep -q "unknown"; then
  echo "   ⚠️  HPA metrics not yet available — may take 1-2 min"
else
  echo "   ✅ HPA reporting: $HPA_STATUS"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$ERRORS" -eq 0 ]; then
  echo "✅ Bootstrap complete — all checks passed"
else
  echo "⚠️  Bootstrap finished with $ERRORS warning(s)"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "🌐 Access your service:"
echo "   API:       curl http://localhost:8080/api/v1/data"
echo "   ArgoCD UI: http://localhost:8082  (see install_argo.sh for port-forward)"
echo ""
echo "📊 Monitoring:"
echo "   kubectl get pods -n service-ns"
echo "   kubectl get hpa -n service-ns"
echo "   kubectl top pods -n service-ns"
echo ""
echo "🧹 Cleanup:"
echo "   ./k8s/cleanup.sh"
echo ""
