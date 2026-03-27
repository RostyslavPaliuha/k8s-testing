#!/bin/bash

# Build and deploy service to Kubernetes
# Usage: ./k8s/build-and-deploy.sh [version]
# Examples:
#   ./k8s/build-and-deploy.sh       # Uses 'latest'
#   ./k8s/build-and-deploy.sh 0.0.2 # Uses specific version

set -e

VERSION=${1:-latest}
IMAGE="service:$VERSION"

echo "🔨 Building Docker image: $IMAGE"
docker build -t $IMAGE --file ../

echo ""
echo "🚀 Updating Kubernetes deployment..."
kubectl set image deployment/service-deployment -n service-ns service=$IMAGE

echo ""
echo "⏳ Waiting for rollout to complete..."
kubectl rollout status deployment -n service-ns service-deployment

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Check status:"
echo "   kubectl get pods -n service-ns"
echo ""
echo "🌐 Access the service:"
echo "   ./k8s/port-forward.sh"
echo "   curl localhost:30081/api/v1/data"
