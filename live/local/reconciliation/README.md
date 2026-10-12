# Flux reconciliation

This directory is the orchestration layer included by the [local root Kustomization](../kustomization.yaml). Its Flux Kustomizations point to the [namespace overlays](../namespaces/) and [global overlays](../_global/) that compose reusable components into deployable resources.

The definitions encode dependency and health-check ordering: [chart sources](sources.yaml) precede the [Istio control plane](istio-control-plane.yaml), [Istio ingress](istio-ingress.yaml), and [applications](main.yaml), while [Kyverno](kyverno.yaml) precedes the [cluster policies](kyverno-policies.yaml).
