#!/bin/bash

# Quick load test script for the service
# Usage: ./k8s/load-test.sh [requests] [concurrency]

REQUESTS=${1:-1000}
CONCURRENCY=${2:-10}
URL="http://localhost:30081/api/v1/data"

echo "🚀 Load Testing: $URL"
echo "📊 Requests: $REQUESTS"
echo "🔀 Concurrency: $CONCURRENCY"
echo ""

# Check if k6 is installed
if command -v k6 &> /dev/null; then
    echo "✅ Using k6 for load testing..."
    k6 run --vus $CONCURRENCY --iterations $REQUESTS - <<EOF
import http from 'k6/http';
import { check } from 'k6';

export let options = {
  vus: $CONCURRENCY,
  iterations: $REQUESTS,
};

export default function () {
  let res = http.get('$URL');
  check(res, {
    'status is 200': (r) => r.status === 200,
  });
}
EOF

# Check if hey is installed
elif command -v hey &> /dev/null; then
    echo "✅ Using hey for load testing..."
    hey -n $REQUESTS -c $CONCURRENCY $URL

# Check if ab (Apache Bench) is installed
elif command -v ab &> /dev/null; then
    echo "✅ Using Apache Bench for load testing..."
    ab -n $REQUESTS -c $CONCURRENCY $URL

# Check if vegeta is installed
elif command -v vegeta &> /dev/null; then
    echo "✅ Using vegeta for load testing..."
    echo "GET $URL" | vegeta attack -rate=10 -duration=10s | vegeta report

# Fallback: simple curl loop
else
    echo "⚠️  No load testing tool found. Using simple curl loop..."
    echo "💡 Install k6, hey, ab, or vegeta for better results"
    echo ""
    
    START=$(date +%s)
    SUCCESS=0
    FAILED=0
    
    for i in $(seq 1 $REQUESTS); do
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $URL)
        if [ "$RESPONSE" == "200" ]; then
            ((SUCCESS++))
        else
            ((FAILED++))
        fi
        
        # Progress indicator
        if [ $((i % 100)) -eq 0 ]; then
            echo "Progress: $i/$REQUESTS requests..."
        fi
    done
    
    END=$(date +%s)
    DURATION=$((END - START))
    
    echo ""
    echo "✅ Results:"
    echo "   Total requests: $REQUESTS"
    echo "   Successful: $SUCCESS"
    echo "   Failed: $FAILED"
    echo "   Duration: ${DURATION}s"
    echo "   Requests/sec: $((REQUESTS / DURATION))"
fi
