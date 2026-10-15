terraform {
  source = "${get_repo_root()}/infra/modules/platform"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  cluster_vars = read_terragrunt_config(find_in_parent_folders("cluster.hcl"))
  secret_path  = "${get_repo_root()}/infra/live/local/secrets/dex-config.sops.yaml"
  secret       = yamldecode(sops_decrypt_file(local.secret_path))
}

inputs = {
  dex_chart_version     = local.cluster_vars.locals.versions.dex_chart
  dex_config            = local.secret.stringData["config.yaml"]
  dex_password          = local.secret.stringData.password
  dex_secret_revision   = parseint(substr(md5(file(local.secret_path)), 0, 7), 16)
  istio_chart_version   = local.cluster_vars.locals.versions.istio_chart
  kyverno_chart_version = local.cluster_vars.locals.versions.kyverno_chart
}
