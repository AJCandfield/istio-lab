terraform {
  source = "${get_repo_root()}/infra/modules/platform-config"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../platform"]
}
