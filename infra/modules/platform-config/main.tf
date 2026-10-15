locals {
  manifests = {
    for filename in fileset("${path.module}/manifests", "*.yaml") :
    trimsuffix(basename(filename), ".yaml") => yamldecode(file("${path.module}/manifests/${filename}"))
  }
}

resource "kubernetes_manifest" "resources" {
  for_each = local.manifests
  manifest = each.value
}
