terraform {
  source = "${get_repo_root()}/infra/modules/kyverno"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../_resources/namespace"]
}

locals {
  service_vars = read_terragrunt_config(find_in_parent_folders("service.hcl"))
}

inputs = {
  chart_version = local.service_vars.locals.service.chart_version
}
