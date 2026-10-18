locals {
  available_policies = {
    for filename in fileset("${path.module}/manifests", "*.yaml") :
    trimsuffix(filename, ".yaml") => yamldecode(file("${path.module}/manifests/${filename}"))
  }
  mandatory_policies = toset(["disallow-default-namespace"])
  enabled_policies = (
    var.policies == null ?
    toset([]) :
    setunion(local.mandatory_policies, var.policies)
  )
}

moved {
  from = helm_release.kyverno
  to   = helm_release.this[0]
}

resource "helm_release" "this" {
  count = var.install_chart ? 1 : 0

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

moved {
  from = kubernetes_manifest.disallow_default_namespace
  to   = kubernetes_manifest.this["disallow-default-namespace"]
}

resource "kubernetes_manifest" "this" {
  for_each = local.enabled_policies

  manifest = local.available_policies[each.value]

  depends_on = [helm_release.this]
}
