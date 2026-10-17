terraform {
  source = "${get_repo_root()}/infra/modules/flux-instance"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../flux-operator", "../platform-config"]
}

locals {
  cluster_vars = read_terragrunt_config(find_in_parent_folders("cluster.hcl"))
  secret_path  = "${get_repo_root()}/infra/live/local/secrets/flux-git-credentials.sops.yaml"
  secret       = yamldecode(sops_decrypt_file(local.secret_path))
}

inputs = {
  flux_version        = local.cluster_vars.locals.versions.flux
  git_password        = base64decode(local.secret.data.password)
  git_ref             = local.cluster_vars.locals.git_ref
  git_secret_revision = parseint(substr(md5(file(local.secret_path)), 0, 7), 16)
  git_url             = local.cluster_vars.locals.git_url
  git_username        = base64decode(local.secret.data.username)
}
