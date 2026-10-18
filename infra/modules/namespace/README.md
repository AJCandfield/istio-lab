# Kubernetes namespace

Creates a Kubernetes namespace with optional labels and annotations.

`ignore_metadata_changes` is necessary for namespaces whose metadata is extended by in-cluster controllers. When enabled, Terraform retains the requested metadata at creation but does not repeatedly remove controller-managed labels or annotations on later applies.

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
| [kubernetes_namespace_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/3.3.0/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.this_with_external_metadata](https://registry.terraform.io/providers/hashicorp/kubernetes/3.3.0/docs/resources/namespace_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_annotations"></a> [annotations](#input\_annotations) | Annotations to apply to the Kubernetes namespace. | `map(string)` | `{}` | no |
| <a name="input_ignore_metadata_changes"></a> [ignore\_metadata\_changes](#input\_ignore\_metadata\_changes) | Whether to allow in-cluster controllers to manage namespace annotations and labels after creation. | `bool` | `false` | no |
| <a name="input_kube_context"></a> [kube\_context](#input\_kube\_context) | Kubernetes context for the target cluster. | `string` | n/a | yes |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to the kubeconfig containing the target cluster. | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to the Kubernetes namespace. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Kubernetes namespace. | `string` | n/a | yes |
<!-- END_TF_DOCS -->
