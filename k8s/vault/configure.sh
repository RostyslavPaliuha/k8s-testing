#!/bin/bash

# Configures the Kubernetes auth method so the agent injector can actually
# authenticate, plus a KV v2 mount and one example policy/role pair.
#
# Without this the injector is installed and holds valid certificates but has
# no way to log in, so secret injection silently does nothing.
#
# The chart's authDelegator ClusterRoleBinding (enabled by default) lets Vault
# validate service-account tokens using its own pod identity, so no static
# token_reviewer_jwt is needed.

set -euo pipefail

NAMESPACE="${VAULT_NAMESPACE:-vault-ns}"
POD="${VAULT_POD:-vault-0}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INIT_FILE="$SCRIPT_DIR/.vault-init.json"

# Example binding. Change these to the workload you actually want to grant.
APP_NAME="${VAULT_APP_NAME:-demo-app}"
APP_SA="${VAULT_APP_SA:-default}"
APP_NAMESPACE="${VAULT_APP_NAMESPACE:-demo-catalog-ns}"

if [[ ! -s "$INIT_FILE" ]]; then
  echo "❌ ${INIT_FILE} not found — run init.sh first"
  exit 1
fi

ROOT_TOKEN="$(python3 -c "import json,sys;print(json.load(open(sys.argv[1]))['root_token'])" "$INIT_FILE")"

if [[ -z "$ROOT_TOKEN" ]]; then
  echo "❌ Could not read root_token from ${INIT_FILE}"
  exit 1
fi

echo "🔧 Configuring Vault"

# The whole configuration runs as a single script piped over stdin, so the root
# token never appears in argv or in the pod's process list.
kubectl exec -n "$NAMESPACE" -i "$POD" -- sh -s <<EOF
set -e
export VAULT_TOKEN='${ROOT_TOKEN}'

if vault auth list -format=json | grep -q '"kubernetes/"'; then
  echo "   Kubernetes auth already enabled, skipping"
else
  echo "   Enabling Kubernetes auth..."
  vault auth enable kubernetes
fi

echo "   Pointing Kubernetes auth at the in-cluster API server..."
vault write auth/kubernetes/config \
  kubernetes_host="https://\${KUBERNETES_PORT_443_TCP_ADDR}:443"

if vault secrets list -format=json | grep -q '"secret/"'; then
  echo "   KV v2 already mounted at secret/, skipping"
else
  echo "   Mounting KV v2 at secret/..."
  vault secrets enable -path=secret kv-v2
fi

echo "   Writing policy ${APP_NAME}-read..."
printf '%s\n' \
  'path "secret/data/${APP_NAME}/*" {' \
  '  capabilities = ["read"]' \
  '}' \
  'path "secret/metadata/${APP_NAME}/*" {' \
  '  capabilities = ["read", "list"]' \
  '}' > /tmp/${APP_NAME}-read.hcl
vault policy write ${APP_NAME}-read /tmp/${APP_NAME}-read.hcl
rm -f /tmp/${APP_NAME}-read.hcl

echo "   Binding ServiceAccount ${APP_NAMESPACE}/${APP_SA} to that policy..."
vault write auth/kubernetes/role/${APP_NAME} \
  bound_service_account_names="${APP_SA}" \
  bound_service_account_namespaces="${APP_NAMESPACE}" \
  policies="${APP_NAME}-read" \
  ttl=24h
EOF

echo "✅ Vault configured"
echo "   Auth path: auth/kubernetes   Role: ${APP_NAME}   Policy: ${APP_NAME}-read"
echo "   Store a test secret with:"
echo "     kubectl exec -n ${NAMESPACE} ${POD} -- vault kv put secret/${APP_NAME}/config key=value"
