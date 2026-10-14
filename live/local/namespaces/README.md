# Namespace overlays

This directory contains the namespace-scoped overlays for the local environment. Each child directory combines reusable [`k8s/components`](../../../k8s/components/) resources with local namespace definitions and, where needed, k3d-specific Helm values.

The overlays are organized by namespace:

- [`flux`](flux/) contains the Istio and Kyverno Helm repository sources used by Flux.
- [`istio-system`](istio-system/) contains the Istio base and control-plane releases with their local Helm values.
- [`istio-ingress`](istio-ingress/) contains the Istio ingress gateway release with its local Helm values.
- [`kyverno`](kyverno/) contains the Kyverno controller release.
- [`main`](main/) contains the frontend, orders, and payments applications and enables mesh injection.

Infrastructure namespaces remain outside the mesh.
