terraform {
  source = "${get_repo_root()}/infra/modules/kyverno-policies"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../controller"]
}
