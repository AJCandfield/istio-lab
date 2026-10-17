terraform {
  source = "${get_repo_root()}/infra/modules/istio-ingress"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../_resources", "../../istio-system/control-plane"]
}

locals {
  cluster_vars = read_terragrunt_config(find_in_parent_folders("cluster.hcl"))
}

inputs = {
  chart_version = local.cluster_vars.locals.versions.istio_chart
}
