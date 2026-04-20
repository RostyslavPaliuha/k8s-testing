#!/bin/bash

set -euo pipefail

usage() {
  echo "Usage: $0 {gateway|authorization|resource|all}"
}

port_forward() {
  local namespace="$1"
  local service="$2"
  local debug_port="$3"
  local jmx_port="$4"

  echo "Forwarding ${service} in ${namespace}: localhost:${debug_port}->9876 localhost:${jmx_port}->9875"
  kubectl port-forward -n "$namespace" "svc/$service" "${debug_port}:9876" "${jmx_port}:9875"
}

port_forward_bg() {
  local namespace="$1"
  local service="$2"
  local debug_port="$3"
  local jmx_port="$4"

  echo "Starting background port-forward for ${service}: localhost:${debug_port}->9876 localhost:${jmx_port}->9875"
  kubectl port-forward -n "$namespace" "svc/$service" "${debug_port}:9876" "${jmx_port}:9875" &
}

target="${1:-}"

case "$target" in
  gateway)
    port_forward "ingress-gateway-ns" "ingress-gateway" "19876" "19875"
    ;;
  authorization)
    port_forward "authorization-server-ns" "authorization-server" "29876" "29875"
    ;;
  resource)
    port_forward "service-ns" "service" "39876" "39875"
    ;;
  all)
    port_forward_bg "ingress-gateway-ns" "ingress-gateway" "19876" "19875"
    port_forward_bg "authorization-server-ns" "authorization-server" "29876" "29875"
    port_forward_bg "service-ns" "service" "39876" "39875"
    wait
    ;;
  *)
    usage
    exit 1
    ;;
esac
