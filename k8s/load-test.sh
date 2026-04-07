#!/bin/bash

# Wrapper to run the k6 load test
# Usage: ./load-test.sh [env vars]
#   MAX_VUS=100 DURATION=300 ./load-test.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v k6 &> /dev/null; then
  echo "❌ k6 is not installed. Install it with:"
  echo "   brew install k6   (macOS)"
  exit 1
fi

echo "🚀 Starting k6 load test..."
echo ""

k6 run "$SCRIPT_DIR/load-test.js" "$@"
