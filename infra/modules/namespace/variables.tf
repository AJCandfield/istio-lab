variable "kubeconfig_path" {
  description = "Path to the kubeconfig containing the target cluster."
  type        = string
}

variable "kube_context" {
  description = "Kubernetes context for the target cluster."
  type        = string
}

variable "name" {
  description = "Name of the Kubernetes namespace."
  type        = string
}

variable "annotations" {
  description = "Annotations to apply to the Kubernetes namespace."
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Labels to apply to the Kubernetes namespace."
  type        = map(string)
  default     = {}
}

variable "ignore_metadata_changes" {
  description = "Whether to allow in-cluster controllers to manage namespace annotations and labels after creation."
  type        = bool
  default     = false
}
