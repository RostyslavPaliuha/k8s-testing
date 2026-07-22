#!/bin/bash

# Initialises Vault on first start and stores the init output locally.
#
# Vault's readiness probe is `vault status`, which only succeeds once the node
# is initialised and unsealed. That means the pod stays NotReady until this
# script runs — so it must run before any `kubectl rollout status`.
#
# The awskms seal unseals the node automatically, both here and on every later
# restart, so this script never needs to unseal anything itself. The keys it
# produces are recovery keys, not unseal keys.
#
# Production runs the same seal against real KMS, but initialisation there
# should be a manual ceremony with PGP-encrypted key shares
# (`-recovery-shares`/`-pgp-keys`) and the root token revoked afterwards.
# Writing the root token to disk, as below, is a local-development shortcut.

set -euo pipefail

NAMESPACE="${VAULT_NAMESPACE:-vault-ns}"
POD="${VAULT_POD:-vault-0}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INIT_FILE="$SCRIPT_DIR/.vault-init.json"

wait_for_pod_running() {
  local attempts=60

  echo "   Waiting for ${POD} to reach Running..."
  for ((i=1; i<=attempts; i++)); do
    local phase
    phase="$(kubectl get pod -n "$NAMESPACE" "$POD" \
      -o jsonpath='{.status.phase}' 2>/dev/null || true)"

    if [[ "$phase" == "Running" ]]; then
      echo "✅ ${POD} is Running (not Ready yet — that is expected pre-init)"
      return 0
    fi
    sleep 5
  done

  echo "❌ ${POD} did not reach Running in time"
  kubectl get pods -n "$NAMESPACE" 2>/dev/null || true
  return 1
}

vault_exec() {
  kubectl exec -n "$NAMESPACE" "$POD" -- "$@"
}

echo "🔐 Initialising Vault"

wait_for_pod_running

# `vault operator init -status` exits 0 when initialised, 2 when not.
set +e
vault_exec vault operator init -status >/dev/null 2>&1
init_status=$?
set -e

if [[ $init_status -eq 0 ]]; then
  echo "✅ Vault is already initialised, skipping"
  exit 0
fi

if [[ $init_status -ne 2 ]]; then
  echo "❌ Could not read init status from ${POD} (exit ${init_status})"
  echo "   The seal is the usual cause — check that LocalStack is running and"
  echo "   that alias/vault-unseal exists in eu-central-1:"
  echo "     kubectl logs -n localstack-ns deploy/localstack | grep vault-kms"
  vault_exec vault status || true
  exit 1
fi

if [[ -s "$INIT_FILE" ]]; then
  echo "❌ ${INIT_FILE} exists but Vault reports uninitialised."
  echo "   Refusing to overwrite it — move it aside if this is a fresh cluster."
  exit 1
fi

echo "   Running vault operator init..."
umask 077
vault_exec vault operator init -format=json > "$INIT_FILE"
chmod 600 "$INIT_FILE"

echo "✅ Vault initialised and auto-unsealed via KMS"
echo "   🔑 Recovery keys and root token: ${INIT_FILE} (mode 600, gitignored)"
echo "   ⚠️  Local-development storage only. In production these come out of a"
echo "      PGP-encrypted init ceremony and the root token is revoked."
