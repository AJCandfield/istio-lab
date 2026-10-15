resource "kubernetes_secret_v1" "git_credentials" {
  metadata {
    name      = "flux-system"
    namespace = "flux"
  }

  data_wo = {
    username = var.git_username
    password = var.git_password
  }
  data_wo_revision = var.git_secret_revision
  type             = "Opaque"
}

resource "kubernetes_manifest" "flux" {
  manifest = yamldecode(templatefile("${path.module}/manifests/flux-instance.yaml.tftpl", {
    flux_version = var.flux_version
    git_ref      = var.git_ref
    git_url      = var.git_url
  }))

  depends_on = [kubernetes_secret_v1.git_credentials]
}
