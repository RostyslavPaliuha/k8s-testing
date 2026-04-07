import http from 'k6/http';
import { check, sleep } from 'k6';

/**
 * k6 Load Test — Ramp Up → Hold → Ramp Down
 *
 * ═══════════════════════════════════════════════════
 * INSTALLATION
 * ═══════════════════════════════════════════════════
 *   macOS:  brew install k6
 *   Linux:  sudo snap install k6
 *   Docker: docker.io/loadimpact/k6
 *
 * ═══════════════════════════════════════════════════
 * USAGE
 * ═══════════════════════════════════════════════════
 *   # Default: 50 VUs max, 180s total (60/60/60)
 *   k6 run load-test.js
 *
 *   # Custom max VUs and duration
 *   k6 run --env MAX_VUS=100 --env DURATION=300 load-test.js
 *
 *   # Custom URL
 *   k6 run --env URL=http://localhost:8080/api/v1/data load-test.js
 *
 *   # Combined
 *   k6 run \
 *     --env MAX_VUS=200 \
 *     --env DURATION=300 \
 *     --env URL=http://localhost:8080/api/v1/data \
 *     load-test.js
 *
 * ═══════════════════════════════════════════════════
 * ENVIRONMENT VARIABLES
 * ═══════════════════════════════════════════════════
 *   URL       — Target endpoint  (default: http://localhost:8080/api/v1/data)
 *   MAX_VUS   — Peak virtual users (default: 50)
 *   DURATION  — Total test time in seconds, split 3 ways (default: 180)
 *
 * ═══════════════════════════════════════════════════
 * RAMP PROFILE (default: 180s, MAX_VUS=50)
 * ═══════════════════════════════════════════════════
 *   Phase      Duration   VU ramp
 *   ──────────────────────────────────
 *   Ramp Up    60s        0 → 50
 *   Hold       60s        50 (steady)
 *   Ramp Down  60s        50 → 0
 *
 * ═══════════════════════════════════════════════════
 * OUTPUT
 * ═══════════════════════════════════════════════════
 *   k6 prints a real-time progress table and a final
 *   summary with:
 *     • http_req_duration  (avg, min, med, p90, p95, p99, max)
 *     • http_reqs          (requests/sec throughput)
 *     • http_req_failed    (error rate %)
 *     • checks             (pass/fail ratio)
 */

const URL = __ENV.URL || 'http://localhost:8080/api/v1/data';
const MAX_VUS = parseInt(__ENV.MAX_VUS || '50', 10);
const DURATION = parseInt(__ENV.DURATION || '180', 10);

const rampUp = Math.floor(DURATION / 3);
const hold = Math.floor(DURATION / 3);
const rampDown = DURATION - rampUp - hold;

export const options = {
  stages: [
    { duration: `${rampUp}s`, target: MAX_VUS },
    { duration: `${hold}s`, target: MAX_VUS },
    { duration: `${rampDown}s`, target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],   // 95th percentile must be < 500ms
    http_req_failed:   ['rate<0.1'],    // error rate must be < 10%
  },
};

export default function () {
  const res = http.get(URL);

  check(res, {
    'status is 200': (r) => r.status === 200,
    'response has body': (r) => r.body.length > 0,
  });

  sleep(1 / MAX_VUS);
}
