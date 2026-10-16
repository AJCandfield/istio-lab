variable "kubeconfig_path" {
  description = "Path to the kubeconfig containing the target cluster."
  type        = string
}

variable "kube_context" {
  description = "Kubernetes context for the target cluster."
  type        = string
}

variable "istio_chart_version" {
  description = "Version shared by the Istio Helm charts."
  type        = string
}

variable "kyverno_chart_version" {
  description = "Kyverno Helm chart version."
  type        = string
}
