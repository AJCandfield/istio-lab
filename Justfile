set shell := ["bash", "-euo", "pipefail", "-c"]

cluster-up:
    k3d cluster create --config k3d.yaml

cluster-down:
    k3d cluster delete istio-lab

flux-bootstrap branch="main":
    @FLUX_GIT_BRANCH="{{branch}}" mise exec -- bash -euo pipefail -c 'test -n "${FLUX_GITHUB_TOKEN:-}"; [[ "$FLUX_GIT_BRANCH" =~ ^[A-Za-z0-9._/-]+$ ]]; kubectl apply --server-side --force-conflicts -k flux/system; for deploy in $(kubectl -n flux-system get deployments -o jsonpath='{.items[*].metadata.name}'); do kubectl -n flux-system rollout status "deployment/$deploy" --timeout=5m; done; printf %s "$FLUX_GITHUB_TOKEN" | kubectl -n flux-system create secret generic flux-system --from-literal=username=git --from-file=password=/dev/stdin --dry-run=client -o yaml | kubectl apply -f -; kubectl apply -f flux/system/gotk-sync.yaml; kubectl -n flux-system patch gitrepository flux-system --type=merge -p "{\"spec\":{\"ref\":{\"branch\":\"$FLUX_GIT_BRANCH\"}}}"; flux reconcile kustomization flux-system --with-source; flux check'

flux-use-branch branch:
    @FLUX_GIT_BRANCH="{{branch}}" mise exec -- bash -euo pipefail -c '[[ "$FLUX_GIT_BRANCH" =~ ^[A-Za-z0-9._/-]+$ ]]; kubectl -n flux-system patch gitrepository flux-system --type=merge -p "{\"spec\":{\"ref\":{\"branch\":\"$FLUX_GIT_BRANCH\"}}}"; flux reconcile kustomization flux-system --with-source'

flux-status:
    flux get all --all-namespaces

debug-curl-up:
    kubectl apply -f tools/debug-curl/deployment.yaml
    kubectl rollout status deployment/debug-curl --namespace istio-lab
    kubectl exec --stdin --tty --namespace istio-lab --container debug-tools deployment/debug-curl -- /bin/sh || [ "$?" -eq 130 ]

debug-curl-down:
    kubectl delete -f tools/debug-curl/deployment.yaml --ignore-not-found

validate:
    @tmp="$(mktemp)"; trap 'rm -f "$tmp"' EXIT; flux install --export > "$tmp"; diff -u flux/system/gotk-components.yaml "$tmp"
    @while IFS= read -r dir; do kubectl kustomize "$dir" >/dev/null; done < <(find flux -name kustomization.yaml -exec dirname {} \; | sort)
