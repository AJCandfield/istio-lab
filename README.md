# Istio Lab

Install the project tools and Git hooks:

```sh
mise install
pre-commit install
```

The repository uses Flux to reconcile the lab components. Flux installs Istio and Kyverno from pinned Helm charts and applies the lab services to the `main` namespace from Kubernetes manifests. The debug container remains an imperative local tool.

## Git credentials

Create a fine-grained GitHub token that can read repository contents. The token is stored in the root `.env.json`, encrypted with SOPS and a repository-specific age identity at `~/.config/mise/istio-lab-age.txt`. Mise decrypts the file when it loads the project environment.

The public age recipient is committed in `.sops.yaml`; never commit the private identity or a plaintext token. CI disables Mise environment loading and does not receive the age identity.

## Bootstrap

The Operator setup replaces the generated Flux installation and does not support an in-place handoff. Delete any existing local cluster and recreate it from these instructions.

Create the local cluster and the mesh-excluded Flux namespace:

```sh
k3d cluster create --config k3d.yaml
kubectl apply -f live/local/bootstrap/flux-system/namespace.yaml
```

Install the pinned Flux Operator chart. Its values keep the operator outside the mesh and set a conservative resource envelope for the local machine:

```sh
helm upgrade --install flux-operator \
  oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator \
  --version 0.61.0 \
  --namespace flux-system \
  --values live/local/bootstrap/flux-system/operator-values.yaml \
  --wait
```

Decrypt and apply the Git credential Secret, then apply the Flux instance. The encrypted Secret is safe to store in the public repository; its age identity remains local. The operator installs Flux 2.9.6 and creates the `flux-system` Git source and root Kustomization:

```sh
SOPS_AGE_KEY_FILE="$HOME/.config/mise/istio-lab-age.txt" \
  sops decrypt live/local/bootstrap/flux-system/git-credentials.sops.yaml | kubectl apply -f -
kubectl apply -f live/local/bootstrap/flux-system/flux-instance.yaml
kubectl -n flux-system wait fluxinstance/flux --for=condition=Ready --timeout=10m
flux reconcile kustomization flux-system --with-source
flux check
```

The Flux instance is bootstrap-owned rather than reconciled by the root Kustomization. To validate an unmerged branch, update its sync reference and wait for the operator to regenerate the source:

```sh
kubectl -n flux-system patch fluxinstance flux --type=merge \
  -p '{"spec":{"sync":{"ref":"refs/heads/<branch>"}}}'
generation=$(kubectl -n flux-system get fluxinstance flux -o jsonpath='{.metadata.generation}')
kubectl -n flux-system wait fluxinstance/flux \
  --for="jsonpath={.status.conditions[?(@.type=='Ready')].observedGeneration}=$generation" \
  --timeout=10m
flux reconcile kustomization flux-system --with-source
```

Use `refs/heads/main` with the same commands to switch the cluster back after the branch merges, before deleting the branch.

Inspect reconciliation with `flux get all --all-namespaces` and inspect the operator-managed installation with `kubectl -n flux-system get fluxinstance,fluxreport`.

Teardown the cluster with `k3d cluster delete istio-lab`.

## Debug container

Open an interactive shell in the debug container with `just debug-curl-up` and remove it with `just debug-curl-down`.
