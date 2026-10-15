variable "kubeconfig_path" {
  description = "Path to the kubeconfig containing the target cluster."
  type        = string
}

variable "kube_context" {
  description = "Kubernetes context for the target cluster."
  type        = string
}

variable "chart_version" {
  description = "Flux Operator Helm chart version."
  type        = string
}

variable "flux_web_config" {
  description = "Decrypted Flux Web configuration."
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "flux_web_config_revision" {
  description = "Revision used to update the write-only Flux Web Secret."
  type        = number
}
