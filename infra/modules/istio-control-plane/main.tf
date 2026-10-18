resource "helm_release" "base" {
  name       = "istio-base"
  namespace  = "istio-system"
  repository = "https://blob.istio.io/istio-release/charts"
  chart      = "base"
  version    = var.chart_version

  cleanup_on_fail = true
  timeout         = 300
  values          = [file("${path.module}/values/base.yaml")]
  wait            = true
}

resource "helm_release" "istiod" {
  name       = "istiod"
  namespace  = "istio-system"
  repository = "https://blob.istio.io/istio-release/charts"
  chart      = "istiod"
  version    = var.chart_version

  cleanup_on_fail = true
  timeout         = 300
  values          = [file("${path.module}/values/istiod.yaml")]
  wait            = true

  depends_on = [helm_release.base]
}
