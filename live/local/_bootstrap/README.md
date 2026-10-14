# Bootstrap resources

This directory contains the resources needed to install Flux on the cluster.
These resources must exist before GitOps can reconcile the rest of the environment.

Bootstrap resources are intentionally excluded from the [local root Kustomization](../kustomization.yaml) because Flux cannot own its own initial setup.

## Bootstrap

From the repository root, use Helmfile to create the `flux` namespace and install the pinned Flux Operator chart. Its values keep the operator outside the mesh and set a conservative resource envelope for the local machine:

```sh
helmfile --file live/local/_bootstrap/helmfile.yaml sync
```

Decrypt and apply the Git credential Secret, then apply the Flux instance. Its password field is encrypted and safe to store in the public repository; the age identity remains local. The operator installs Flux 2.9.6 and creates the `flux-system` Git source and root Kustomization:

```bash
# Decrypt and apply the Git credential Secret.
SOPS_AGE_KEY_FILE="$HOME/.config/mise/istio-lab-age.txt" \
  sops decrypt live/local/_bootstrap/flux/git-credentials.sops.yaml | kubectl apply -f -
```

```bash
# Apply the Flux instance.
kubectl apply -f live/local/_bootstrap/flux/instance.yaml
```

```bash
# Wait for the Flux instance to become ready.
kubectl -n flux wait fluxinstance/flux --for=condition=Ready --timeout=10m
```

```bash
# Reconcile the root Kustomization and its Git source.
flux reconcile kustomization flux-system --namespace flux --with-source
```

```bash
# Verify that Flux is installed and healthy.
flux check
```

The Flux instance is bootstrap-owned rather than reconciled by the root Kustomization. To validate an unmerged branch, update its sync reference and wait for the operator to regenerate the source:

```sh
kubectl -n flux patch fluxinstance flux --type=merge \
  -p '{"spec":{"sync":{"ref":"refs/heads/<branch>"}}}'
generation=$(kubectl -n flux get fluxinstance flux -o jsonpath='{.metadata.generation}')
kubectl -n flux wait fluxinstance/flux \
  --for="jsonpath={.status.conditions[?(@.type=='Ready')].observedGeneration}=$generation" \
  --timeout=10m
flux reconcile kustomization flux-system --namespace flux --with-source
```

Use `refs/heads/main` with the same commands to switch the cluster back after the branch merges, before deleting the branch.

Inspect reconciliation with `flux get all --all-namespaces` and inspect the operator-managed installation with `kubectl -n flux get fluxinstance,fluxreport`.
