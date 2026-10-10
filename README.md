# Istio Lab

Install the project tools and Git hooks:

```sh
mise install
pre-commit install
```

The repository uses Flux to reconcile the lab components. Flux installs Istio and Kyverno from pinned Helm charts and applies the lab services from Kubernetes manifests. The debug container remains an imperative local tool.

## Git credentials

Create a fine-grained GitHub token that can read repository contents. The token is stored in the root `.env.json`, encrypted with SOPS and a repository-specific age identity at `~/.config/mise/istio-lab-age.txt`. Mise decrypts the file when it loads the project environment.

The public age recipient is committed in `.sops.yaml`; never commit the private identity or a plaintext token. CI disables Mise environment loading and does not receive the age identity.

## Bootstrap

Create the local cluster and install the Flux controllers, then wait for the controllers to roll out:

```sh
k3d cluster create --config k3d.yaml
kubectl apply --server-side --force-conflicts -k flux/system
for deploy in $(kubectl -n flux-system get deployments -o jsonpath='{.items[*].metadata.name}'); do
  kubectl -n flux-system rollout status "deployment/$deploy" --timeout=5m
done
```

Create the Git credential Secret, apply the Git source and root Kustomization, and trigger reconciliation:

```sh
printf %s "$FLUX_GITHUB_TOKEN" | kubectl -n flux-system create secret generic flux-system \
  --from-literal=username=git --from-file=password=/dev/stdin \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f flux/system/gotk-sync.yaml
flux reconcile kustomization flux-system --with-source
flux check
```

The Git source in `flux/system/gotk-sync.yaml` defaults to `main` and is applied during bootstrap, not by the root Kustomization, so pointing the live source at an unmerged branch for validation is not reverted by reconciliation:

```sh
kubectl -n flux-system patch gitrepository flux-system --type=merge -p '{"spec":{"ref":{"branch":"<branch>"}}}'
flux reconcile kustomization flux-system --with-source
```

Use the same commands with `main` to switch the cluster back after the branch merges, before deleting the branch.

Inspect reconciliation with `flux get all --all-namespaces`. Run the offline validation and the other repository checks with:

```sh
pre-commit run --all-files
```

Teardown the cluster with `k3d cluster delete istio-lab`.

## Debug container

Open an interactive shell in the debug container with `just debug-curl-up` and remove it with `just debug-curl-down`.
