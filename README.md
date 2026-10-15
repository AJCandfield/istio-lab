# Istio Lab

This repository provisions a local k3d service-mesh lab with a hybrid Terraform and GitOps workflow:

- k3d creates and deletes the local cluster.
- Terragrunt and Terraform own the platform: Flux, Istio, Kyverno, Dex, cluster policy, namespaces, and bootstrap Secrets.
- Flux reconciles the application manifests under [`k8s/components/apps`](k8s/components/apps/).

## Prerequisites

Install and start Docker, then place the repository age identity at `~/.config/mise/istio-lab-age.txt`. The identity must match the public recipient in [`.sops.yaml`](.sops.yaml); obtain it through a secure channel rather than committing it.

Install the pinned tools and Git hooks:

```sh
mise install
pre-commit install
```

## Provision the lab

```sh
just up
```

This creates the k3d cluster when necessary, applies the Terragrunt units in dependency order, waits for Flux, and reconciles the applications. Every Kubernetes command is pinned to `k3d-istio-lab`; `KUBECONFIG` may select the file containing that context.

Use `just plan` to inspect platform changes and `just check` to inspect cluster and Flux health. On an unbootstrapped cluster, planning covers the base units and reports CRD-dependent units as skipped until their controllers are installed. See [`infra/README.md`](infra/README.md) for ownership boundaries, configuration, state, secrets, and teardown.

Clusters created before the Terragrunt migration do not have compatible Terraform state. Delete and recreate such a cluster before the first `just up`:

```sh
just cluster-delete
just up
```

The `istio-lab-dex` Docker volume survives cluster deletion.

## Flux source

Flux defaults to this repository's `main` branch. A pushed fork or feature branch can be tested with fully qualified overrides:

```sh
FLUX_GIT_URL=https://github.com/example/istio-lab.git \
FLUX_GIT_REF=refs/heads/example-branch \
just up
```

## Debug container

Open an interactive shell in the debug container with `just debug-curl-up` and remove it with `just debug-curl-down`.
