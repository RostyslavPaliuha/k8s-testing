#!/bin/bash
set -e
echo "🔌 Setting up port forwarding..."
kubectl port-forward  service-ingress 8081:80 -n service-ns

