variable "kubeconfig_path" {
  description = "Path to the kubeconfig containing the target cluster."
  type        = string
}

variable "kube_context" {
  description = "Kubernetes context for the target cluster."
  type        = string
}

variable "dex_chart_version" {
  description = "Dex Helm chart version."
  type        = string
}

variable "dex_config" {
  description = "Decrypted Dex configuration."
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "dex_password" {
  description = "Decrypted password for the local Dex test user."
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "dex_secret_revision" {
  description = "Revision used to update the write-only Dex Secret."
  type        = number
}

variable "istio_chart_version" {
  description = "Version shared by the Istio Helm charts."
  type        = string
}

variable "kyverno_chart_version" {
  description = "Kyverno Helm chart version."
  type        = string
}
