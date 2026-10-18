# Istio Lab

This repository provisions a local k3d service-mesh lab with a hybrid Terraform and GitOps workflow:

- k3d creates and deletes the local cluster.
- Terragrunt and Terraform own the platform: Flux, Istio, Kyverno, cluster policy, namespaces, and bootstrap Secrets.
- Flux reconciles the application manifests under [`k8s/components/apps`](k8s/components/apps/).

## Prerequisites

Install and start Docker, then place the repository age identity at `~/.config/mise/istio-lab-age.txt`. The identity must match the public recipient in [`.sops.yaml`](.sops.yaml); obtain it through a secure channel rather than committing it.

Install the pinned tools and Git hooks:

```sh
mise install
mise exec -- pre-commit install
```

## Provision the lab

```sh
mise exec -- k3d cluster create --config k3d.yaml
mise exec -- terragrunt run --all apply --working-dir infra/live/local --non-interactive --tf-path terraform
```

The Terragrunt units install Flux and the platform in dependency order. Flux then reconciles the applications. `KUBECONFIG` may select the file containing the fixed `k3d-istio-lab` context. See [`infra/README.md`](infra/README.md) for ownership boundaries, configuration, state, secrets, and teardown.

## Flux source

Flux defaults to this repository's `main` branch. A pushed fork or feature branch can be tested with fully qualified overrides:

```sh
FLUX_GIT_URL=https://github.com/example/istio-lab.git \
FLUX_GIT_REF=refs/heads/example-branch \
mise exec -- terragrunt run --all apply --working-dir infra/live/local --non-interactive --tf-path terraform
```

## Debug container

The optional debug container manifest and usage commands are documented in [`tools/README.md`](tools/README.md).
