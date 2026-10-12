# Namespace overlays

This directory contains the namespace-scoped overlays for the local environment. Each child directory combines reusable [`k8s/components`](../../../k8s/components/) resources with local namespace definitions and, where needed, k3d-specific Helm values.

The [Flux namespace](flux-system/) publishes chart sources, the [Istio control-plane](istio-system/), [Istio ingress](istio-ingress/), and [Kyverno](kyverno/) overlays install infrastructure, and the [`main` overlay](main/) deploys the lab applications. The application namespace is mesh-enabled, while infrastructure namespaces remain outside the mesh.
