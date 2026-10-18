terraform {
  source = "${get_repo_root()}/infra/modules/kyverno"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../controller"]
}

inputs = {
  install_chart = false
  policies      = []
}
