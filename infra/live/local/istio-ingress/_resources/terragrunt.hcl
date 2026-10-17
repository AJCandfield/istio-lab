terraform {
  source = "${get_repo_root()}/infra/modules/namespace"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  name = "istio-ingress"
}
