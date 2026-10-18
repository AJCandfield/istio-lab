moved {
  from = helm_release.flux_operator
  to   = helm_release.this
}

resource "helm_release" "this" {
  name             = "flux-operator"
  namespace        = "flux"
  chart            = "oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator"
  version          = var.chart_version
  create_namespace = false

  cleanup_on_fail = true
  timeout         = 300
  values          = [file("${path.module}/values.yaml")]
  wait            = true
}
