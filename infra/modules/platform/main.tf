locals {
  namespace_manifests = {
    for filename in fileset("${path.module}/manifests/namespaces", "*.yaml") :
    trimsuffix(basename(filename), ".yaml") => yamldecode(file("${path.module}/manifests/namespaces/${filename}"))
  }
}

resource "kubernetes_manifest" "namespaces" {
  for_each = local.namespace_manifests
  manifest = each.value
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
  namespace  = "istio-system"
  repository = "https://blob.istio.io/istio-release/charts"
  chart      = "base"
  version    = var.istio_chart_version

  cleanup_on_fail = true
  timeout         = 300
  values          = [file("${path.module}/values/istio-base.yaml")]
  wait            = true

  depends_on = [kubernetes_manifest.namespaces]
}

resource "helm_release" "istiod" {
  name       = "istiod"
  namespace  = "istio-system"
  repository = "https://blob.istio.io/istio-release/charts"
  chart      = "istiod"
  version    = var.istio_chart_version

  cleanup_on_fail = true
  timeout         = 300
  values          = [file("${path.module}/values/istiod.yaml")]
  wait            = true

  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_ingress" {
  name       = "istio-ingress"
  namespace  = "istio-ingress"
  repository = "https://blob.istio.io/istio-release/charts"
  chart      = "gateway"
  version    = var.istio_chart_version

  cleanup_on_fail = true
  timeout         = 300
  values          = [file("${path.module}/values/istio-ingress.yaml")]
  wait            = true

  depends_on = [helm_release.istiod]
}

resource "helm_release" "kyverno" {
  name       = "kyverno"
  namespace  = "kyverno"
  repository = "https://kyverno.github.io/kyverno"
  chart      = "kyverno"
  version    = var.kyverno_chart_version

  cleanup_on_fail = true
  timeout         = 300
  values          = [file("${path.module}/values/kyverno.yaml")]
  wait            = true

  depends_on = [kubernetes_manifest.namespaces]
}
