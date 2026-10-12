# Istio Lab

Install the project tools and Git hooks:

```sh
mise install
pre-commit install
```

The repository uses Flux to reconcile the lab components. Flux installs Istio and Kyverno from pinned Helm charts and applies the lab services to the `main` namespace from Kubernetes manifests. Infrastructure workloads remain outside the mesh. The ingress gateway uses Istio's gateway injection template to configure its primary proxy container; it does not receive an additional sidecar. The debug container remains an imperative local tool.

See the [bootstrap instructions](live/local/_bootstrap/README.md#bootstrap) to create the local cluster and install Flux.

## Git credentials

Create a fine-grained GitHub token that can read repository contents. The token is stored in the root [`.env.json`](.env.json), encrypted with SOPS and a repository-specific age identity at `~/.config/mise/istio-lab-age.txt`. Mise decrypts the file when it loads the project environment.

The public age recipient is committed in [`.sops.yaml`](.sops.yaml); never commit the private identity or a plaintext token. CI disables Mise environment loading and does not receive the age identity.

## Debug container

Open an interactive shell in the debug container with `just debug-curl-up` and remove it with `just debug-curl-down`.
