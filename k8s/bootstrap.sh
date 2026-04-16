#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
METRICS_VERSION="v0.7.2"

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
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

  echo "   Waiting for ArgoCD server to be ready..."
  kubectl rollout status deployment argocd-server -n argocd --timeout=300s
  sleep 10
  PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
  echo "✅ ArgoCD installed"
  echo "   🔑 Admin password: $PASSWORD"
  kubectl apply -f "$SCRIPT_DIR/argo-application-authorization-server.yml"
  kubectl apply -f "$SCRIPT_DIR/argo-application-ingress-gateway.yml"
  kubectl apply -f "$SCRIPT_DIR/argo-application-resource-server.yml"
fi
## ingress controller

# ── 4. PostgreSQL ────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🐘 Step 4/6: Installing PostgreSQL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if kubectl get deployment postgres -n service-ns &>/dev/null; then
  echo "✅ PostgreSQL already installed, skipping"
else
  echo "   Deploying PostgreSQL..."
  kubectl apply -f "$SCRIPT_DIR/postgres-app.yml"

  echo "   Waiting for PostgreSQL to be ready..."
  kubectl rollout status deployment postgres -n service-ns --timeout=120s
  echo "✅ PostgreSQL installed"
fi

# ── 5. Redis ─────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔴 Step 5/6: Installing Redis"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if kubectl get deployment redis -n service-ns &>/dev/null; then
  echo "✅ Redis already installed, skipping"
else
  echo "   Deploying Redis..."
  kubectl apply -f "$SCRIPT_DIR/redis-app.yml"

  echo "   Waiting for Redis to be ready..."
  kubectl rollout status deployment redis -n service-ns --timeout=120s
  echo "✅ Redis installed"
fi

# ── 6. Deploy Service via ArgoCD ─────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Step 6/6: Deploying Service (via ArgoCD)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "   Creating ArgoCD Application..."
kubectl apply -f "$SCRIPT_DIR/argocd/argocd_service_definition.yml"

echo "   Waiting for resources to be created..."
sleep 15

echo "   Waiting for service deployment to be ready..."
kubectl rollout status deployment service-deployment -n service-ns --timeout=300s

echo "✅ Service deployed"

# ── 7. Verify Everything ─────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Step 7/6: Final Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

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
echo "   PostgreSQL:"
if kubectl get deployment postgres -n service-ns -o jsonpath='{.status.readyReplicas}' 2>/dev/null | grep -q "1"; then
  echo "   ✅ postgres ready"
else
  echo "   ❌ postgres not ready"
  ERRORS=$((ERRORS + 1))
fi

echo ""
echo "   Redis:"
if kubectl get deployment redis -n service-ns -o jsonpath='{.status.readyReplicas}' 2>/dev/null | grep -q "1"; then
  echo "   ✅ redis ready"
else
  echo "   ❌ redis not ready"
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
echo "   Service:"
if kubectl get deployment service-deployment -n service-ns -o jsonpath='{.status.readyReplicas}' 2>/dev/null | grep -q "1"; then
  echo "   ✅ service-deployment ready"
else
  echo "   ❌ service-deployment not ready"
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
