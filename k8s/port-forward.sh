#!/bin/bash

set -e

echo "🔌 Setting up port forwarding..."
echo ""
echo "🌐 Service will be available at: http://localhost:30081"
echo "📍 Endpoint: http://localhost:30081/api/v1/data"
echo ""
echo "Press Ctrl+C to stop port forwarding"
echo ""

kubectl port-forward -n service-ns svc/service 30081:8081
