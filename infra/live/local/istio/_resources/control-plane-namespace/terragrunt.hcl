terraform {
  source = "${get_repo_root()}/infra/modules/namespace"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  service_vars = read_terragrunt_config(find_in_parent_folders("service.hcl"))
}

inputs = local.service_vars.locals.service.namespaces.control_plane
