#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Deploying service to Kubernetes..."

# Apply namespace
echo "📦 Creating namespace..."
kubectl apply -f "$SCRIPT_DIR/namespace.yaml"

# Apply all resources
echo "📦 Applying resources..."
kubectl apply -f "$SCRIPT_DIR/configmap.yaml"
kubectl apply -f "$SCRIPT_DIR/deployment.yaml"
kubectl apply -f "$SCRIPT_DIR/service.yaml"
kubectl apply -f "$SCRIPT_DIR/hpa.yaml"
kubectl apply -f "$SCRIPT_DIR/ingress.yaml"

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Check status:"
echo "   kubectl get pods -n service-ns"
echo "   kubectl get hpa -n service-ns"
echo "   kubectl get svc -n service-ns"
echo ""
echo "🌐 Access the service:"
echo "   curl <node-ip>:30081/api/v1/data"
echo "   # On local machine: curl localhost:30081/api/v1/data"
echo ""
echo "🔍 View logs:"
echo "   kubectl logs -n service-ns -l app=service"
echo ""
echo "📈 Scale manually:"
echo "   kubectl scale deployment -n service-ns service-deployment --replicas=5"
