locals {
  service = {
    name = "flux"

    namespace = {
      name                    = "flux"
      ignore_metadata_changes = true
      labels = {
        "istio-injection" = "disabled"
      }
    }

    source = {
      url = get_env("FLUX_GIT_URL", "https://github.com/AJCandfield/istio-lab.git")
      ref = get_env("FLUX_GIT_REF", "refs/heads/main")
    }

    versions = {
      # renovate: datasource=github-releases depName=fluxcd/flux2
      flux = "2.9.6"
      # renovate: datasource=helm depName=flux-operator registryUrl=oci://ghcr.io/controlplaneio-fluxcd/charts
      operator_chart = "0.61.0"
    }
  }
}
