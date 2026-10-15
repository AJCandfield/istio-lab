# Platform infrastructure

Terragrunt composes the local platform from the Terraform modules in this directory. The k3d cluster remains CLI-managed because the available community Terraform provider does not track the repository's pinned k3d version closely enough.

## Hierarchy and ownership

Reusable Terraform modules are kept under `modules`, while `live` contains the Terragrunt root, local-cluster context, ordered units, and encrypted inputs.

The Terragrunt dependency order is:

1. `flux-operator` installs the operator and its Web UI bootstrap Secret.
2. `platform` installs Istio, Kyverno, Dex, namespaces, persistence, and cluster DNS configuration.
3. `platform-config` applies resources that require the Istio and Kyverno CRDs.
4. `flux-instance` installs Flux with a configurable Git source.

Flux owns only the application reconciliation under [`live/local`](../live/local/). A resource must not be managed by both Terraform and Flux.

## Configuration

[`live/local/cluster.hcl`](live/local/cluster.hcl) contains local versions and defaults. These environment variables override machine- or invocation-specific values:

| Variable | Default |
| --- | --- |
| `KUBECONFIG` | `$HOME/.kube/config` |
| `FLUX_GIT_URL` | `https://github.com/AJCandfield/istio-lab.git` |
| `FLUX_GIT_REF` | `refs/heads/main` |

Use a fully qualified Git ref such as `refs/heads/my-branch`. The context is intentionally fixed to `k3d-istio-lab`, and every Terraform operation verifies the context, cluster name, expected server node, and API readiness before accessing state.

## State and secrets

Each Terragrunt leaf keeps local Terraform state beside its `terragrunt.hcl`; state and backup files are ignored by Git. The committed `.terraform.lock.hcl` files pin provider checksums.

Encrypted inputs live under [`live/local/secrets`](live/local/secrets/). Terragrunt decrypts them with SOPS and passes the values through ephemeral Terraform variables. The Kubernetes provider writes them through `data_wo`, so plaintext values are not persisted in Terraform state. The encrypted-file hash supplies the write-only revision, causing a Secret update whenever its SOPS file changes.

Edit a Secret with the repository age identity:

```sh
sops infra/live/local/secrets/dex-config.sops.yaml
sops infra/live/local/secrets/flux-git-credentials.sops.yaml
sops infra/live/local/secrets/flux-web-config.sops.yaml
```

## Lifecycle

Run `mise exec -- just --list` for the authoritative lifecycle tasks. Platform destruction leaves the k3d cluster intact, while cluster deletion retains the `istio-lab-dex` Docker volume. The storage deletion task removes that retained identity data explicitly.

## Local Dex user

The encrypted Dex configuration declares `test@istio-lab.localhost` as a static user. Retrieve its generated password when needed:

```sh
kubectl --context k3d-istio-lab --namespace dex get secret dex-config \
  --output=jsonpath='{.data.password}' | base64 --decode
```

Sign in at `http://flux.localhost:8080`. The local `flux-web-test-user` ClusterRoleBinding grants this identity the `flux-web-admin` role and must not be copied to shared environments.
