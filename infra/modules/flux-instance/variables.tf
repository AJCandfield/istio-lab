variable "kubeconfig_path" {
  description = "Path to the kubeconfig containing the target cluster."
  type        = string
}

variable "kube_context" {
  description = "Kubernetes context for the target cluster."
  type        = string
}

variable "flux_version" {
  description = "Flux distribution version installed by the Flux Operator."
  type        = string
}

variable "git_url" {
  description = "GitHub repository reconciled by Flux."
  type        = string

  validation {
    condition     = startswith(var.git_url, "https://github.com/")
    error_message = "git_url must use HTTPS on github.com because Flux attaches the Git credential Secret."
  }
}

variable "git_ref" {
  description = "Fully qualified Git ref reconciled by Flux."
  type        = string
}

variable "git_username" {
  description = "Git HTTPS credential username."
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "git_password" {
  description = "Git HTTPS credential password."
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "git_secret_revision" {
  description = "Revision used to update the write-only Git credential Secret."
  type        = number
}
