resource "kubernetes_namespace_v1" "flux" {
  metadata {
    name = "flux"

    labels = {
      "istio-injection" = "disabled"
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

resource "kubernetes_secret_v1" "web_config" {
  metadata {
    name      = "flux-web-config"
    namespace = kubernetes_namespace_v1.flux.metadata[0].name
  }

  data_wo = {
    "config.yaml" = var.flux_web_config
  }
  data_wo_revision = var.flux_web_config_revision
}

resource "helm_release" "flux_operator" {
  name             = "flux-operator"
  namespace        = kubernetes_namespace_v1.flux.metadata[0].name
  chart            = "oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator"
  version          = var.chart_version
  create_namespace = false

  cleanup_on_fail = true
  timeout         = 300
  values          = [file("${path.module}/values.yaml")]
  wait            = true

  depends_on = [kubernetes_secret_v1.web_config]
}
