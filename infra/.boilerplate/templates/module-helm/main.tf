resource "helm_release" "this" {
  name             = "{{ .ModuleName }}"
  namespace        = "{{ .ModuleName }}"
  repository       = ""
  chart            = ""
  version          = var.chart_version
  create_namespace = false

  cleanup_on_fail = true
  timeout         = 300
  values          = [file("${path.module}/values.yaml")]
  wait            = true
}
