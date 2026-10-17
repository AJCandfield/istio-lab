resource "kubernetes_namespace_v1" "this" {
  count = var.ignore_metadata_changes ? 0 : 1

  metadata {
    name        = var.name
    annotations = var.annotations
    labels      = var.labels
  }
}

resource "kubernetes_namespace_v1" "this_with_external_metadata" {
  count = var.ignore_metadata_changes ? 1 : 0

  metadata {
    name        = var.name
    annotations = var.annotations
    labels      = var.labels
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}
