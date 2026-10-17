locals {
  cluster_vars = read_terragrunt_config(find_in_parent_folders("cluster.hcl"))
  state_path   = "${get_repo_root()}/infra/live/${path_relative_to_include()}/terraform.tfstate"

  helm_units = [
    "local/flux/operator",
    "local/istio-ingress/gateway",
    "local/istio-system/control-plane",
    "local/kyverno/controller",
  ]
  helm_provider = (
    contains(local.helm_units, path_relative_to_include()) ?
    <<-EOF
provider "helm" {
  kubernetes = {
    config_path    = var.kubeconfig_path
    config_context = var.kube_context
  }
}
EOF
    : ""
  )
}

generate "providers" {
  path      = "_providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kube_context
}

${local.helm_provider}
EOF
}

remote_state {
  backend = "local"

  generate = {
    path      = "_backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    path = local.state_path
  }
}

inputs = {
  kubeconfig_path = local.cluster_vars.locals.kubeconfig_path
  kube_context    = local.cluster_vars.locals.kube_context
}

terraform {
  extra_arguments "lock_timeout" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=1m"]
  }

  before_hook "validate_cluster" {
    commands = ["apply", "destroy", "import", "plan", "refresh"]
    execute = [
      "${get_repo_root()}/scripts/verify-local-cluster.sh",
      local.cluster_vars.locals.kubeconfig_path,
      local.cluster_vars.locals.kube_context,
    ]
    run_on_error = false
  }
}
