# Istio control plane

Installs the Istio base resources and control plane into an existing `istio-system` namespace.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 3.3.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.3.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.base](https://registry.terraform.io/providers/hashicorp/helm/3.3.0/docs/resources/release) | resource |
| [helm_release.istiod](https://registry.terraform.io/providers/hashicorp/helm/3.3.0/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Version shared by the Istio Helm charts. | `string` | n/a | yes |
| <a name="input_kube_context"></a> [kube\_context](#input\_kube\_context) | Kubernetes context for the target cluster. | `string` | n/a | yes |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to the kubeconfig containing the target cluster. | `string` | n/a | yes |
<!-- END_TF_DOCS -->
