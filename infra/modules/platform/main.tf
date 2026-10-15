locals {
  namespace_manifests = {
    for filename in fileset("${path.module}/manifests/namespaces", "*.yaml") :
    trimsuffix(basename(filename), ".yaml") => yamldecode(file("${path.module}/manifests/namespaces/${filename}"))
  }
  resource_manifests = {
    for filename in fileset("${path.module}/manifests/resources", "*.yaml") :
    trimsuffix(basename(filename), ".yaml") => yamldecode(file("${path.module}/manifests/resources/${filename}"))
  }
}

resource "kubernetes_manifest" "namespaces" {
  for_each = local.namespace_manifests
  manifest = each.value
}

resource "kubernetes_secret_v1" "dex_config" {
  metadata {
    name      = "dex-config"
    namespace = "dex"
  }

  data_wo = {
    "config.yaml" = var.dex_config
    password      = var.dex_password
  }
  data_wo_revision = var.dex_secret_revision

  depends_on = [kubernetes_manifest.namespaces]
}

resource "kubernetes_manifest" "resources" {
  for_each = local.resource_manifests
  manifest = each.value

  depends_on = [kubernetes_manifest.namespaces]
}

resource "kubernetes_job_v1" "dex_initialize_data" {
  metadata {
    name      = "dex-initialize-data"
    namespace = "dex"
  }

  spec {
    backoff_limit = 3

    template {
      metadata {}

      spec {
        automount_service_account_token = false
        restart_policy                  = "Never"

        container {
          name    = "initialize-data"
          image   = "busybox:1.37.0"
          command = ["/bin/sh", "-c"]
          args    = ["chown 1001:1001 /var/dex && chmod 0700 /var/dex"]

          resources {
            requests = {
              cpu    = "1m"
              memory = "4Mi"
            }
            limits = {
              cpu    = "20m"
              memory = "16Mi"
            }
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_group               = 1001
            run_as_non_root            = true
            run_as_user                = 1001

            capabilities {
              add  = ["CHOWN"]
              drop = ["ALL"]
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/dex"
          }
        }

        volume {
          name = "data"

          persistent_volume_claim {
            claim_name = "dex"
          }
        }
      }
    }
  }

  wait_for_completion = true

  timeouts {
    create = "2m"
    update = "2m"
  }

  depends_on = [kubernetes_manifest.resources]
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
  namespace  = "istio-system"
  repository = "https://blob.istio.io/istio-release/charts"
  chart      = "base"
  version    = var.istio_chart_version

  cleanup_on_fail = true
  timeout         = 300
  values          = [file("${path.module}/values/istio-base.yaml")]
  wait            = true

  depends_on = [kubernetes_manifest.namespaces]
}

resource "helm_release" "istiod" {
  name       = "istiod"
  namespace  = "istio-system"
  repository = "https://blob.istio.io/istio-release/charts"
  chart      = "istiod"
  version    = var.istio_chart_version

  cleanup_on_fail = true
  timeout         = 300
  values          = [file("${path.module}/values/istiod.yaml")]
  wait            = true

  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_ingress" {
  name       = "istio-ingress"
  namespace  = "istio-ingress"
  repository = "https://blob.istio.io/istio-release/charts"
  chart      = "gateway"
  version    = var.istio_chart_version

  cleanup_on_fail = true
  timeout         = 300
  values          = [file("${path.module}/values/istio-ingress.yaml")]
  wait            = true

  depends_on = [helm_release.istiod]
}

resource "helm_release" "kyverno" {
  name       = "kyverno"
  namespace  = "kyverno"
  repository = "https://kyverno.github.io/kyverno"
  chart      = "kyverno"
  version    = var.kyverno_chart_version

  cleanup_on_fail = true
  timeout         = 300
  values          = [file("${path.module}/values/kyverno.yaml")]
  wait            = true

  depends_on = [kubernetes_manifest.namespaces]
}

resource "helm_release" "dex" {
  name       = "dex"
  namespace  = "dex"
  repository = "https://charts.dexidp.io"
  chart      = "dex"
  version    = var.dex_chart_version

  cleanup_on_fail = true
  timeout         = 300
  values          = [file("${path.module}/values/dex.yaml")]
  wait            = true

  depends_on = [
    kubernetes_job_v1.dex_initialize_data,
    kubernetes_secret_v1.dex_config,
  ]
}
