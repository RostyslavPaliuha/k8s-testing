#!/bin/bash
set -e

echo "🔌 Setting up port forwarding..."

# Find the running pod
POD=$(kubectl get pods -n service-ns -l app=service -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD" ]; then
  echo "❌ No running pods found in service-ns namespace"
  exit 1
fi

echo "📦 Forwarding pod/$POD:8081 to localhost:8080"
kubectl port-forward -n service-ns "pod/$POD" 8080:8081

