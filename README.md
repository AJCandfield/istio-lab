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

Create the local cluster and bootstrap Flux against the default branch:

```sh
just cluster-up
just flux-bootstrap
```

The Git source and root Kustomization in `flux/system/gotk-sync.yaml` are applied by the bootstrap recipe rather than the root Kustomization, so the live branch override during feature validation is not reverted by reconciliation.

To validate an unmerged branch, pass its name explicitly:

```sh
just flux-bootstrap feat/migrate-to-flux
```

Inspect reconciliation with `just flux-status`. After merging a feature branch, run `just flux-use-branch main` before deleting the branch.

Open an interactive shell in the debug container with `just debug-curl-up` and remove it with `just debug-curl-down`.

Run repository validation with:

```sh
just validate
pre-commit run --all-files
```
