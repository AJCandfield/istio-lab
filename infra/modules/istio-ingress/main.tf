resource "helm_release" "gateway" {
  name       = "istio-ingress"
  namespace  = "istio-ingress"
  repository = "https://blob.istio.io/istio-release/charts"
  chart      = "gateway"
  version    = var.chart_version

  cleanup_on_fail = true
  timeout         = 300
  values          = [file("${path.module}/values.yaml")]
  wait            = true
}

resource "kubernetes_manifest" "gateway" {
  manifest = yamldecode(file("${path.module}/manifests/gateway.yaml"))

  depends_on = [helm_release.gateway]
}
