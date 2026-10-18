# Platform infrastructure

Terragrunt composes the local platform from the Terraform modules in this directory. The k3d cluster remains CLI-managed because the available community Terraform provider does not track the repository's pinned k3d version closely enough.

## Hierarchy and ownership

Reusable Terraform modules are kept under `modules`. Deployments and CRD-backed configuration use component-specific modules, while the small `namespace` module is shared. The Terragrunt units under `live/local` are grouped by Kubernetes namespace; each `_resources/namespace` unit creates its parent namespace with the typed Kubernetes provider resource.

The dependency order is:

1. The `_resources/namespace` units create the `flux`, `istio-system`, `istio-ingress`, `kyverno`, and `main` namespaces.
2. `flux/operator`, `istio-system/control-plane`, and `kyverno/controller` install their Helm releases.
3. `istio-ingress/gateway` installs the ingress release and its Istio `Gateway`, while `kyverno/policies` uses the Kyverno module in policy-only mode after the Kyverno CRDs exist.
4. `flux/instance` creates the Git credentials, Flux instance, and the Flux UI's Istio route.

Custom resources are represented by `kubernetes_manifest`; built-in resources use typed Kubernetes provider resources when available. Flux owns only the application reconciliation under [`live/local`](../live/local/). A resource must not be managed by both Terraform and Flux.

Create new modules with `mise exec -- just make-tf-module`. The scaffold supplies the standard file layout and provider constraints. The terraform-docs pre-commit hook updates only modules with changed Terraform files and preserves hand-written README content outside its marker block.

## Configuration

[`live/local/cluster.hcl`](live/local/cluster.hcl) contains local versions and defaults. These environment variables override machine- or invocation-specific values:

| Variable | Default |
| --- | --- |
| `KUBECONFIG` | `$HOME/.kube/config` |
| `FLUX_GIT_URL` | `https://github.com/AJCandfield/istio-lab.git` |
| `FLUX_GIT_REF` | `refs/heads/main` |

Use a fully qualified Git ref such as `refs/heads/my-branch`. The context is intentionally fixed to `k3d-istio-lab`, and every Terraform operation verifies the context, cluster name, expected server node, and API readiness before accessing state.

## State and secrets

Terragrunt keeps local Terraform state under each unit path, and state and backup files are ignored by Git. Namespace units write state to their parent `_resources` directory while their configuration lives in `_resources/namespace`. The committed `.terraform.lock.hcl` files pin provider checksums.

Encrypted inputs live under [`live/local/secrets`](live/local/secrets/). Terragrunt decrypts them with SOPS and passes the values through ephemeral Terraform variables. The Kubernetes provider writes them through `data_wo`, so plaintext values are not persisted in Terraform state. The encrypted-file hash supplies the write-only revision, causing a Secret update whenever its SOPS file changes.

Edit the Git credential Secret with the repository age identity:

```sh
sops infra/live/local/secrets/flux-git-credentials.sops.yaml
```

## Lifecycle

Run Terragrunt from the repository root against `infra/live/local`. Applying or destroying all units follows their dependency graph; destroying the platform leaves the k3d cluster intact.
