#!/bin/bash

set -euo pipefail

usage() {
  echo "Usage: $0 {gateway|authorization|resource|observability|all}"
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

port_forward_service_bg() {
  local namespace="$1"
  local service="$2"
  local local_port="$3"
  local service_port="$4"

  echo "Starting background port-forward for ${service}: localhost:${local_port}->${service_port}"
  kubectl port-forward -n "$namespace" "svc/$service" "${local_port}:${service_port}" &
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
  observability)
    port_forward_service_bg "monitoring" "kube-prometheus-stack-grafana" "3000" "80"
    port_forward_service_bg "monitoring" "kube-prometheus-stack-prometheus" "9090" "9090"
    port_forward_service_bg "monitoring" "tempo" "3200" "3200"
    port_forward_service_bg "monitoring" "loki-gateway" "3100" "80"
    wait
    ;;
  all)
    port_forward_bg "ingress-gateway-ns" "ingress-gateway" "19876" "19875"
    port_forward_bg "authorization-server-ns" "authorization-server" "29876" "29875"
    port_forward_bg "service-ns" "service" "39876" "39875"
    port_forward_service_bg "monitoring" "kube-prometheus-stack-grafana" "3000" "80"
    port_forward_service_bg "monitoring" "kube-prometheus-stack-prometheus" "9090" "9090"
    port_forward_service_bg "monitoring" "tempo" "3200" "3200"
    port_forward_service_bg "monitoring" "loki-gateway" "3100" "80"
    wait
    ;;
  *)
    usage
    exit 1
    ;;
esac
