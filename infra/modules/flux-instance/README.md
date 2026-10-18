# Flux instance

Creates the Flux instance, its write-only Git credentials, and the route used to expose the Flux UI inside the lab.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 3.3.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 3.3.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [kubernetes_manifest.flux](https://registry.terraform.io/providers/hashicorp/kubernetes/3.3.0/docs/resources/manifest) | resource |
| [kubernetes_manifest.route](https://registry.terraform.io/providers/hashicorp/kubernetes/3.3.0/docs/resources/manifest) | resource |
| [kubernetes_secret_v1.git_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/3.3.0/docs/resources/secret_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_flux_version"></a> [flux\_version](#input\_flux\_version) | Flux distribution version installed by the Flux Operator. | `string` | n/a | yes |
| <a name="input_git_password"></a> [git\_password](#input\_git\_password) | Git HTTPS credential password. | `string` | n/a | yes |
| <a name="input_git_ref"></a> [git\_ref](#input\_git\_ref) | Fully qualified Git ref reconciled by Flux. | `string` | n/a | yes |
| <a name="input_git_secret_revision"></a> [git\_secret\_revision](#input\_git\_secret\_revision) | Revision used to update the write-only Git credential Secret. | `number` | n/a | yes |
| <a name="input_git_url"></a> [git\_url](#input\_git\_url) | GitHub repository reconciled by Flux. | `string` | n/a | yes |
| <a name="input_git_username"></a> [git\_username](#input\_git\_username) | Git HTTPS credential username. | `string` | n/a | yes |
| <a name="input_kube_context"></a> [kube\_context](#input\_kube\_context) | Kubernetes context for the target cluster. | `string` | n/a | yes |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to the kubeconfig containing the target cluster. | `string` | n/a | yes |
<!-- END_TF_DOCS -->
