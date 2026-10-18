locals {
  service = {
    name = "kyverno"

    namespace = {
      name = "kyverno"
      labels = {
        "istio-injection" = "disabled"
      }
    }

    # renovate: datasource=helm depName=kyverno registryUrl=https://kyverno.github.io/kyverno
    chart_version = "3.9.1"
  }
}
