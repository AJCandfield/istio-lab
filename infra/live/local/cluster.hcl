locals {
  kube_context    = "k3d-istio-lab"
  kubeconfig_path = get_env("KUBECONFIG", "${get_env("HOME")}/.kube/config")

  git_url = get_env("FLUX_GIT_URL", "https://github.com/AJCandfield/istio-lab.git")
  git_ref = get_env("FLUX_GIT_REF", "refs/heads/main")

  versions = {
    # renovate: datasource=helm depName=dex registryUrl=https://charts.dexidp.io
    dex_chart = "0.24.1"
    # renovate: datasource=github-releases depName=fluxcd/flux2
    flux = "2.9.6"
    # renovate: datasource=helm depName=flux-operator registryUrl=oci://ghcr.io/controlplaneio-fluxcd/charts
    flux_operator_chart = "0.61.0"
    # renovate: datasource=github-releases depName=istio/istio
    istio_chart = "1.31.1"
    # renovate: datasource=helm depName=kyverno registryUrl=https://kyverno.github.io/kyverno
    kyverno_chart = "3.9.1"
  }
}
