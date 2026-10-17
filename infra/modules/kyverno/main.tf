resource "helm_release" "kyverno" {
  name       = "kyverno"
  namespace  = "kyverno"
  repository = "https://kyverno.github.io/kyverno"
  chart      = "kyverno"
  version    = var.chart_version

  cleanup_on_fail = true
  timeout         = 300
  values          = [file("${path.module}/values.yaml")]
  wait            = true
}
