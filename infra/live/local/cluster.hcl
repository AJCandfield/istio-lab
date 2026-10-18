locals {
  kube_context    = "k3d-istio-lab"
  kubeconfig_path = get_env("KUBECONFIG", "${get_env("HOME")}/.kube/config")
}
