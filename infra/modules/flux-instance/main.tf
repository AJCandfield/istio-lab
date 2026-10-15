resource "kubernetes_secret_v1" "git_credentials" {
  metadata {
    name      = "flux-system"
    namespace = "flux"
  }

  data_wo = {
    username = var.git_username
    password = var.git_password
  }
  data_wo_revision = var.git_secret_revision
  type             = "Opaque"
}

resource "kubernetes_manifest" "flux" {
  manifest = {
    apiVersion = "fluxcd.controlplane.io/v1"
    kind       = "FluxInstance"
    metadata = {
      name      = "flux"
      namespace = "flux"
    }
    spec = {
      distribution = {
        version  = var.flux_version
        registry = "ghcr.io/fluxcd"
        artifact = "oci://ghcr.io/controlplaneio-fluxcd/flux-operator-manifests"
      }
      components = [
        "source-controller",
        "kustomize-controller",
        "helm-controller",
        "notification-controller",
      ]
      cluster = {
        type          = "kubernetes"
        size          = "small"
        networkPolicy = true
      }
      sync = {
        kind       = "GitRepository"
        url        = var.git_url
        ref        = var.git_ref
        path       = "./live/local"
        pullSecret = kubernetes_secret_v1.git_credentials.metadata[0].name
      }
      kustomize = {
        patches = [
          {
            target = {
              kind = "Namespace"
              name = "flux"
            }
            patch = <<-PATCH
              - op: add
                path: /metadata/labels/istio-injection
                value: disabled
            PATCH
          },
          {
            target = {
              kind = "Deployment"
            }
            patch = <<-PATCH
              - op: add
                path: /spec/template/metadata/annotations/sidecar.istio.io~1inject
                value: "false"
            PATCH
          },
          {
            target = {
              kind = "Deployment"
            }
            patch = <<-PATCH
              - op: replace
                path: /spec/template/spec/containers/0/resources
                value:
                  requests:
                    cpu: 50m
                    memory: 64Mi
                  limits:
                    cpu: 250m
                    memory: 256Mi
            PATCH
          },
          {
            target = {
              kind = "Deployment"
              name = "source-controller"
            }
            patch = <<-PATCH
              - op: replace
                path: /spec/template/spec/containers/0/resources
                value:
                  requests:
                    cpu: 50m
                    memory: 64Mi
                  limits:
                    cpu: 500m
                    memory: 512Mi
            PATCH
          },
          {
            target = {
              kind = "Deployment"
              name = "(kustomize-controller|helm-controller)"
            }
            patch = <<-PATCH
              - op: replace
                path: /spec/template/spec/containers/0/resources
                value:
                  requests:
                    cpu: 100m
                    memory: 64Mi
                  limits:
                    cpu: 500m
                    memory: 512Mi
            PATCH
          },
        ]
      }
    }
  }

  depends_on = [kubernetes_secret_v1.git_credentials]
}
