variable "kubeconfig_path" {
  description = "Path to the kubeconfig containing the target cluster."
  type        = string
}

variable "kube_context" {
  description = "Kubernetes context for the target cluster."
  type        = string
}

variable "chart_version" {
  description = "Kyverno Helm chart version. Required when install_chart is true."
  type        = string
  default     = null

  validation {
    condition     = !var.install_chart || var.chart_version != null
    error_message = "chart_version must be set when install_chart is true."
  }
}

variable "install_chart" {
  description = "Whether to install the Kyverno Helm chart."
  type        = bool
  default     = true
}

variable "policies" {
  description = "Optional policy identifiers to enable. Null disables policy management; any set also enables all mandatory policies."
  type        = set(string)
  default     = null

  validation {
    condition = alltrue([
      for policy in coalesce(var.policies, toset([])) :
      contains([
        for filename in fileset("${path.module}/manifests", "*.yaml") :
        trimsuffix(filename, ".yaml")
      ], policy)
    ])
    error_message = "policies contains an unsupported Kyverno policy identifier."
  }
}
