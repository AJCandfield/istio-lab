moved {
  from = helm_release.gateway
  to   = helm_release.this
}

resource "helm_release" "this" {
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

moved {
  from = kubernetes_manifest.gateway
  to   = kubernetes_manifest.this
}

resource "kubernetes_manifest" "this" {
  manifest = yamldecode(file("${path.module}/manifests/gateway.yaml"))

  depends_on = [helm_release.this]
}
