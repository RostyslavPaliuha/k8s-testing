#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Deploying ingress-gateway to Kubernetes..."

# Apply namespace
echo "📦 Creating namespace..."
kubectl apply -f "$SCRIPT_DIR/namespace.yaml"

# Apply all resources
echo "📦 Applying resources..."
kubectl apply -f "$SCRIPT_DIR/configmap.yaml"
kubectl apply -f "$SCRIPT_DIR/secret.yaml"
kubectl apply -f "$SCRIPT_DIR/deployment.yaml"
kubectl apply -f "$SCRIPT_DIR/service.yaml"
kubectl apply -f "$SCRIPT_DIR/ingress.yaml"

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Check status:"
echo "   kubectl get pods -n ingress-gateway-ns"
echo "   kubectl get svc,ingress -n ingress-gateway-ns"
echo ""
echo "🌐 Access the service:"
echo "   curl http://localhost:8080/"
echo "   # Within cluster: curl http://ingress-gateway.ingress-gateway-ns.svc.cluster.local/..."
echo ""
echo "🔍 View logs:"
echo "   kubectl logs -n ingress-gateway-ns -l app=ingress-gateway"
echo ""
echo "📈 Scale manually:"
echo "   kubectl scale deployment -n ingress-gateway-ns ingress-gateway-deployment --replicas=2"
