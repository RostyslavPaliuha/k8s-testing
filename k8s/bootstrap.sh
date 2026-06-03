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

wait_for_resource_rollout() {
  local resource="$1"
  local namespace="$2"
  local timeout="${3:-600s}"
  local attempts="${4:-60}"

  echo "   Waiting for ${resource} to be created in namespace ${namespace}..."
  for ((i=1; i<=attempts; i++)); do
    if kubectl get "${resource}" -n "${namespace}" &>/dev/null; then
      wait_for_rollout "${resource}" "${namespace}" "${timeout}"
      return 0
    fi
    sleep 10
  done

  echo "❌ ${resource} was not created in namespace ${namespace} in time"
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
echo "📊 Step 1/5: Installing Metrics Server"
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
echo "🅰️  Step 2/5: Installing ArgoCD"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if kubectl get deployment argocd-server -n argocd &>/dev/null; then
  echo "✅ ArgoCD already installed, skipping"
else
  echo "   Creating argocd namespace..."
  kubectl create namespace argocd

  echo "   Installing ArgoCD manifests..."
  kubectl apply --server-side --force-conflicts -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

  if ! kubectl get deployment argocd-server -n argocd &>/dev/null; then
    echo "❌ ArgoCD server deployment not found - installation may have failed"
    exit 1
  fi

  if ! kubectl get crd applicationsets.argoproj.io &>/dev/null; then
    echo "❌ ArgoCD ApplicationSet CRD not found - installation may have failed"
    exit 1
  fi

  wait_for_rollout deployment/argocd-server argocd 300s
  wait_for_rollout deployment/argocd-repo-server argocd 300s
  wait_for_rollout deployment/argocd-applicationset-controller argocd 300s
  wait_for_rollout statefulset/argocd-application-controller argocd 300s
  sleep 10
  PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
  echo "✅ ArgoCD installed"
  echo "   🔑 Admin password: $PASSWORD"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Step 3/5: Applying Cluster Components"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Apply the cluster components"
kubectl apply -f "$SCRIPT_DIR/cluster-components/ingress-controller.yml"
wait_for_ingress_nginx
kubectl apply -f "$SCRIPT_DIR/cluster-components/local.ks.tv.cert-secret.yml"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Step 4/5: Applying ArgoCD Applications"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Apply argocd application definitions"
kubectl apply -f "$SCRIPT_DIR/argocd/bitnami-oci-repository-secret.yml"
kubectl apply -f "$SCRIPT_DIR/argocd/grafana-applications/prometheus.yaml"
kubectl apply -f "$SCRIPT_DIR/argocd/grafana-applications/loki.yaml"
kubectl apply -f "$SCRIPT_DIR/argocd/grafana-applications/opentelemetry-collector.yaml"
kubectl apply -f "$SCRIPT_DIR/argocd/grafana-applications/tempo.yaml"
kubectl apply -f "$SCRIPT_DIR/argocd/argo-application-authorization-server.yml"
kubectl apply -f "$SCRIPT_DIR/argocd/argo-application-ingress-gateway.yml"
kubectl apply -f "$SCRIPT_DIR/argocd/argo-application-demo-catalog.yml"
kubectl apply -f "$SCRIPT_DIR/argocd/argo-application-auth-test-spa.yml"

ERRORS=0

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔭 Step 5/5: Waiting for Observability Stack"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! wait_for_resource_rollout statefulset/prometheus-kube-prometheus-stack-prometheus monitoring 600s; then
  ERRORS=$((ERRORS + 1))
fi
if ! wait_for_resource_rollout statefulset/tempo monitoring 600s; then
  ERRORS=$((ERRORS + 1))
fi
if ! wait_for_resource_rollout deployment/loki-gateway monitoring 600s; then
  ERRORS=$((ERRORS + 1))
fi
if ! wait_for_resource_rollout deployment/opentelemetry-collector monitoring 600s; then
  ERRORS=$((ERRORS + 1))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧩 Waiting for Application Stack"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if ! wait_for_resource_rollout statefulset/postgres-db-postgresql authorization-server-ns 600s; then
  ERRORS=$((ERRORS + 1))
fi
if ! wait_for_resource_rollout deployment/authorization-server-deployment authorization-server-ns 600s; then
  ERRORS=$((ERRORS + 1))
fi
if ! wait_for_resource_rollout deployment/ingress-gateway-deployment ingress-gateway-ns 600s; then
  ERRORS=$((ERRORS + 1))
fi
if ! wait_for_resource_rollout deployment/service-deployment service-ns 600s; then
  ERRORS=$((ERRORS + 1))
fi
if ! wait_for_resource_rollout deployment/demo-catalog-deployment demo-catalog-ns 600s; then
  ERRORS=$((ERRORS + 1))
fi
if ! wait_for_resource_rollout deployment/auth-test-spa-ui-deployment auth-test-spa-ns 600s; then
  ERRORS=$((ERRORS + 1))
fi

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
echo "   Observability:"
if kubectl get application observability-root -n argocd &>/dev/null; then
  echo "   ✅ observability-root applied"
else
  echo "   ❌ observability-root missing"
  ERRORS=$((ERRORS + 1))
fi
if kubectl get deployment opentelemetry-collector -n monitoring -o jsonpath='{.status.readyReplicas}' 2>/dev/null | grep -q "1"; then
  echo "   ✅ opentelemetry-collector ready"
else
  echo "   ❌ opentelemetry-collector not ready"
  ERRORS=$((ERRORS + 1))
fi

if kubectl get statefulset tempo -n monitoring -o jsonpath='{.status.readyReplicas}' 2>/dev/null | grep -q "1"; then
  echo "   ✅ tempo ready"
else
  echo "   ❌ tempo not ready"
  ERRORS=$((ERRORS + 1))
fi
if kubectl get deployment loki-gateway -n monitoring -o jsonpath='{.status.readyReplicas}' 2>/dev/null | grep -q "1"; then
  echo "   ✅ loki ready"
else
  echo "   ❌ loki not ready"
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
echo "   Authorization Server:"
if kubectl get deployment authorization-server-deployment -n authorization-server-ns -o jsonpath='{.status.readyReplicas}' 2>/dev/null | grep -q "1"; then
  echo "   ✅ authorization-server-deployment ready"
else
  echo "   ❌ authorization-server-deployment not ready"
  ERRORS=$((ERRORS + 1))
fi

echo ""
echo "   Authorization Server Database:"
if kubectl get statefulset postgres-db-postgresql -n authorization-server-ns -o jsonpath='{.status.readyReplicas}' 2>/dev/null | grep -q "1"; then
  echo "   ✅ postgres-db-postgresql ready"
else
  echo "   ❌ postgres-db-postgresql not ready"
  ERRORS=$((ERRORS + 1))
fi

echo ""
echo "   Ingress Gateway:"
if kubectl get deployment ingress-gateway-deployment -n ingress-gateway-ns -o jsonpath='{.status.readyReplicas}' 2>/dev/null | grep -q "2"; then
  echo "   ✅ ingress-gateway-deployment ready"
else
  echo "   ❌ ingress-gateway-deployment not ready"
  ERRORS=$((ERRORS + 1))
fi

echo ""
echo "   Demo Catalog:"
if kubectl get deployment demo-catalog-deployment -n demo-catalog-ns -o jsonpath='{.status.readyReplicas}' 2>/dev/null | grep -q "1"; then
  echo "   ✅ demo-catalog-deployment ready"
else
  echo "   ❌ demo-catalog-deployment not ready"
  ERRORS=$((ERRORS + 1))
fi

echo ""
echo "   Auth Test SPA:"
if kubectl get deployment auth-test-spa-ui-deployment -n auth-test-spa-ns -o jsonpath='{.status.readyReplicas}' 2>/dev/null | grep -q "1"; then
  echo "   ✅ auth-test-spa-ui-deployment ready"
else
  echo "   ❌ auth-test-spa-ui-deployment not ready"
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
echo "   API:       curl https://local.ks.tv/resource-server/api/v1/data"
echo "   ArgoCD UI: http://localhost:8082  (see install_argo.sh for port-forward)"
echo "   Debug:     ./k8s/debug/enable.sh"
echo "              ./k8s/debug/port-forward.sh all"
echo "   Grafana:   ./k8s/debug/port-forward.sh observability"
echo ""
echo "📊 Monitoring:"
echo "   kubectl get pods -n service-ns"
echo "   kubectl get hpa -n service-ns"
echo "   kubectl top pods -n service-ns"
echo ""
echo "🧹 Cleanup:"
echo "   ./k8s/cleanup.sh"
echo ""
