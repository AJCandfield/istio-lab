default:
    @just --list

cluster-create:
    #!/usr/bin/env bash
    set -euo pipefail
    kubeconfig="${KUBECONFIG:-$HOME/.kube/config}"
    context="k3d-istio-lab"
    if ! k3d cluster get istio-lab --no-headers 2>/dev/null | grep -q '^istio-lab'; then
      k3d cluster create --config k3d.yaml
    elif ! kubectl --kubeconfig "$kubeconfig" --context "$context" get --raw=/readyz >/dev/null 2>&1; then
      k3d cluster start istio-lab
    fi
    scripts/verify-local-cluster.sh "$kubeconfig" "$context"

up: cluster-create
    #!/usr/bin/env bash
    set -euo pipefail
    kubeconfig="${KUBECONFIG:-$HOME/.kube/config}"
    context="k3d-istio-lab"
    terragrunt run --all apply --working-dir infra/live/local --non-interactive --tf-path terraform
    kubectl --kubeconfig "$kubeconfig" --context "$context" --namespace flux wait fluxinstance/flux --for=condition=Ready --timeout=10m
    flux --kubeconfig "$kubeconfig" --context "$context" reconcile kustomization flux --namespace flux --with-source
    flux --kubeconfig "$kubeconfig" --context "$context" reconcile kustomization apps --namespace flux
    flux --kubeconfig "$kubeconfig" --context "$context" check --namespace flux

plan:
    #!/usr/bin/env bash
    set -euo pipefail
    kubeconfig="${KUBECONFIG:-$HOME/.kube/config}"
    context="k3d-istio-lab"
    scripts/verify-local-cluster.sh "$kubeconfig" "$context"

    base_units=(
      flux/_resources
      flux/operator
      istio-system/_resources
      istio-system/control-plane
      istio-ingress/_resources
      kyverno/_resources
      kyverno/controller
      main/_resources
    )
    for unit in "${base_units[@]}"; do
      terragrunt run plan --working-dir "infra/live/local/$unit" --non-interactive --tf-path terraform
    done

    if kubectl --kubeconfig "$kubeconfig" --context "$context" get crd gateways.networking.istio.io >/dev/null 2>&1; then
      terragrunt run plan --working-dir infra/live/local/istio-ingress/gateway --non-interactive --tf-path terraform
    else
      printf 'Skipping istio-ingress/gateway plan until the Istio Gateway CRD is installed.\n'
    fi
    if kubectl --kubeconfig "$kubeconfig" --context "$context" get crd validatingpolicies.policies.kyverno.io >/dev/null 2>&1; then
      terragrunt run plan --working-dir infra/live/local/kyverno/policies --non-interactive --tf-path terraform
    else
      printf 'Skipping kyverno/policies plan until the Kyverno ValidatingPolicy CRD is installed.\n'
    fi
    if kubectl --kubeconfig "$kubeconfig" --context "$context" get crd fluxinstances.fluxcd.controlplane.io virtualservices.networking.istio.io >/dev/null 2>&1; then
      terragrunt run plan --working-dir infra/live/local/flux/instance --non-interactive --tf-path terraform
    else
      printf 'Skipping flux/instance plan until the FluxInstance and Istio VirtualService CRDs are installed.\n'
    fi

validate:
    scripts/validate-manifests.sh
    scripts/validate-terraform.sh

platform-down:
    terragrunt run --all destroy --working-dir infra/live/local --non-interactive --tf-path terraform

cluster-delete:
    k3d cluster delete istio-lab

check:
    #!/usr/bin/env bash
    set -euo pipefail
    kubeconfig="${KUBECONFIG:-$HOME/.kube/config}"
    context="k3d-istio-lab"
    scripts/verify-local-cluster.sh "$kubeconfig" "$context"
    kubectl --kubeconfig "$kubeconfig" --context "$context" wait node --all --for=condition=Ready --timeout=2m
    kubectl --kubeconfig "$kubeconfig" --context "$context" wait deployment --all --all-namespaces --for=condition=Available --timeout=5m
    kubectl --kubeconfig "$kubeconfig" --context "$context" wait gitrepository --all --namespace flux --for=condition=Ready --timeout=2m
    kubectl --kubeconfig "$kubeconfig" --context "$context" wait kustomization --all --namespace flux --for=condition=Ready --timeout=5m
    kubectl --kubeconfig "$kubeconfig" --context "$context" get nodes
    kubectl --kubeconfig "$kubeconfig" --context "$context" get pods --all-namespaces
    flux --kubeconfig "$kubeconfig" --context "$context" check --namespace flux
    flux --kubeconfig "$kubeconfig" --context "$context" get all --all-namespaces

debug-curl-up:
    #!/usr/bin/env bash
    set -euo pipefail
    kubeconfig="${KUBECONFIG:-$HOME/.kube/config}"
    context="k3d-istio-lab"
    scripts/verify-local-cluster.sh "$kubeconfig" "$context"
    kubectl --kubeconfig "$kubeconfig" --context "$context" apply -f tools/debug-curl/deployment.yaml
    kubectl --kubeconfig "$kubeconfig" --context "$context" rollout status deployment/debug-curl --namespace main
    kubectl --kubeconfig "$kubeconfig" --context "$context" exec --stdin --tty --namespace main --container debug-tools deployment/debug-curl -- /bin/sh || [ "$?" -eq 130 ]

debug-curl-down:
    #!/usr/bin/env bash
    set -euo pipefail
    kubeconfig="${KUBECONFIG:-$HOME/.kube/config}"
    context="k3d-istio-lab"
    scripts/verify-local-cluster.sh "$kubeconfig" "$context"
    kubectl --kubeconfig "$kubeconfig" --context "$context" delete -f tools/debug-curl/deployment.yaml --ignore-not-found
