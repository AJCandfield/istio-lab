resource "kubernetes_manifest" "disallow_default_namespace" {
  manifest = yamldecode(file("${path.module}/manifests/disallow-default-namespace.yaml"))
}
