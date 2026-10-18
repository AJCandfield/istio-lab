locals {
  service = {
    name = "istio"

    namespaces = {
      control_plane = {
        name = "istio-system"
        labels = {
          "istio-injection" = "disabled"
        }
      }
      ingress = {
        name = "istio-ingress"
      }
    }

    # renovate: datasource=github-releases depName=istio/istio
    chart_version = "1.31.1"
  }
}
