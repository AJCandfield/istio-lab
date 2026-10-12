# Global resources

This directory contains local-environment overlays for resources that are cluster-scoped rather than owned by a namespace. These overlays compose definitions from the reusable [`k8s/components`](../../../k8s/components/) layer without mixing them into namespace-specific configuration.

The current [Kyverno policy overlay](kyverno-policies/) selects the reusable cluster policies. Its [Flux reconciliation definition](../reconciliation/kyverno-policies.yaml) waits for the Kyverno controller before applying them.
