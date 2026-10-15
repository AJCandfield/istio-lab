# Bootstrap resources

This directory contains the local cluster overlay needed to install Flux.
It composes the reusable [Flux instance](../../../k8s/components/infra/flux-instance/) and [Flux Operator values](../../../k8s/components/infra/flux-operator/) with local configuration that must exist before GitOps can reconcile the rest of the environment.

Bootstrap resources are intentionally excluded from the [local root Kustomization](../kustomization.yaml) because Flux cannot own its own initial setup.

## Bootstrap

The k3d configuration attaches the Docker volume `istio-lab-dex` to the agent node for the Dex SQLite database. The volume survives cluster deletion and must be removed explicitly with Docker when its identity data is no longer needed. Recreate clusters made with an older `k3d.yaml` so the volume and storage node label are present.

From the repository root, apply the local Dex issuer DNS override and create the bootstrap namespaces, then decrypt and apply the Dex and Flux Web UI configuration Secrets. These Secrets share an OIDC client credential and remain bootstrap-owned so the age identity stays local. The Dex configuration includes a generated local test user; its credentials and user-management workflow are documented in the [Dex component](../../../k8s/components/infra/dex/README.md).

```bash
kubectl apply -f live/local/_bootstrap/coredns-custom.yaml
kubectl create namespace flux --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f live/local/namespaces/dex/namespace.yaml

SOPS_AGE_KEY_FILE="$HOME/.config/mise/istio-lab-age.txt" \
  sops decrypt live/local/_bootstrap/dex/config.sops.yaml | kubectl apply -f -

SOPS_AGE_KEY_FILE="$HOME/.config/mise/istio-lab-age.txt" \
  sops decrypt live/local/_bootstrap/flux/web-config.sops.yaml | kubectl apply -f -
```

Use Helmfile to install the pinned Flux Operator chart. Shared values keep the operator outside the mesh and set a conservative resource envelope, while the local values configure the Web UI to use Dex:

```sh
helmfile --file live/local/_bootstrap/helmfile.yaml sync
```

Decrypt and apply the Git credential Secret, then apply the Flux instance. The operator installs Flux and creates the `flux-system` Git source and root Kustomization:

```bash
# SOPS_AGE_KEY_FILE is needed to retrieve the private key.
sops decrypt live/local/_bootstrap/flux/git-credentials.sops.yaml | kubectl apply -f -
```

```bash
# Render the reusable Flux instance with the local sync configuration and apply it.
kubectl apply -k live/local/_bootstrap/flux
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

The Flux instance is bootstrap-owned rather than reconciled by the root Kustomization.

Inspect reconciliation with `flux get all --all-namespaces` and inspect the operator-managed installation with `kubectl -n flux get fluxinstance,fluxreport`.
