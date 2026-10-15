#!/usr/bin/env bash
set -euo pipefail

kubeconfig="${1:?kubeconfig path is required}"
context="${2:?kube context is required}"

if [ "$context" != "k3d-istio-lab" ]; then
  printf 'refusing to target unexpected context: %s\n' "$context" >&2
  exit 1
fi

cluster=$(kubectl --kubeconfig "$kubeconfig" --context "$context" config view --minify -o jsonpath='{.clusters[0].name}')
if [ "$cluster" != "k3d-istio-lab" ]; then
  printf 'refusing to target unexpected cluster: %s\n' "$cluster" >&2
  exit 1
fi

kubectl --kubeconfig "$kubeconfig" --context "$context" get node k3d-istio-lab-server-0 -o name >/dev/null
kubectl --kubeconfig "$kubeconfig" --context "$context" get --raw=/readyz >/dev/null
