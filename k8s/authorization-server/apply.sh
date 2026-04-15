#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Deploying authorization-server to Kubernetes..."

# Apply namespace
echo "📦 Creating namespace..."
kubectl apply -f "$SCRIPT_DIR/namespace.yaml"

# Apply all resources
echo "📦 Applying resources..."
kubectl apply -f "$SCRIPT_DIR/configmap.yaml"
kubectl apply -f "$SCRIPT_DIR/secret.yaml"
kubectl apply -f "$SCRIPT_DIR/deployment.yaml"
kubectl apply -f "$SCRIPT_DIR/service.yaml"

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Check status:"
echo "   kubectl get pods -n authorization-server-ns"
echo "   kubectl get svc -n authorization-server-ns"
echo ""
echo "🌐 Access the service:"
echo "   curl <node-ip>/authorization/..."
echo "   # Within cluster: curl http://authorization-server.authorization-server-ns.svc.cluster.local/authorization/..."
echo ""
echo "🔍 View logs:"
echo "   kubectl logs -n authorization-server-ns -l app=authorization-server"
echo ""
echo "📈 Scale manually:"
echo "   kubectl scale deployment -n authorization-server-ns authorization-server-deployment --replicas=2"
