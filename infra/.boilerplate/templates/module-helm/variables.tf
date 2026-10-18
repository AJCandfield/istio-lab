variable "kubeconfig_path" {
  description = "Path to the kubeconfig containing the target cluster."
  type        = string
}

variable "kube_context" {
  description = "Kubernetes context for the target cluster."
  type        = string
}

variable "chart_version" {
  description = "Helm chart version."
  type        = string
}
