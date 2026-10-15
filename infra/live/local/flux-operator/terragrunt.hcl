terraform {
  source = "${get_repo_root()}/infra/modules/flux-operator"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  cluster_vars = read_terragrunt_config(find_in_parent_folders("cluster.hcl"))
  secret_path  = "${get_repo_root()}/infra/live/local/secrets/flux-web-config.sops.yaml"
  secret       = yamldecode(sops_decrypt_file(local.secret_path))
}

inputs = {
  chart_version            = local.cluster_vars.locals.versions.flux_operator_chart
  flux_web_config          = local.secret.stringData["config.yaml"]
  flux_web_config_revision = parseint(substr(md5(file(local.secret_path)), 0, 7), 16)
}
