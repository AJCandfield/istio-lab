# Infrastructure components

This directory is the reusable infrastructure layer of the manifest tree. The [Istio](istio/) and [Kyverno](kyverno/) components separate chart sources, controllers or control planes, ingress, and policies so environments can compose only the resources they need.

The [local namespace overlays](../../../live/local/namespaces/) add environment-specific namespaces and Helm values, while the [global overlays](../../../live/local/_global/) select cluster-scoped resources. [Flux reconciliation](../../../live/local/reconciliation/) applies both sets of overlays in dependency order, with infrastructure workloads kept outside the service mesh by default.
