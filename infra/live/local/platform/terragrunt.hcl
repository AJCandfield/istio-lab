terraform {
  source = "${get_repo_root()}/infra/modules/platform"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  cluster_vars = read_terragrunt_config(find_in_parent_folders("cluster.hcl"))
}

inputs = {
  istio_chart_version   = local.cluster_vars.locals.versions.istio_chart
  kyverno_chart_version = local.cluster_vars.locals.versions.kyverno_chart
}
