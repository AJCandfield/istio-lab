# Components

This directory contains reusable, environment-neutral building blocks. Environment overlays choose which components to deploy, assign namespaces, and provide environment-specific configuration.

## Application components

The [application components](apps/) contain each application's Deployment and Service. The local environment composes them in the [`main` namespace overlay](../../live/local/namespaces/main/).

## Infrastructure components

The [infrastructure components](infra/) separate chart sources, controllers or control planes, ingress, and policies so environments can compose only the resources they need. [Namespace overlays](../../live/local/namespaces/) add namespaces and Helm values, while [global overlays](../../live/local/_global/) select cluster-scoped resources. [Flux reconciliation resources](../../live/local/namespaces/flux/reconciliation/) apply those overlays in dependency order. Infrastructure workloads remain outside the service mesh by default.

### Bootstrap components

The [`flux-instance`](infra/flux-instance/) and [`flux-operator`](infra/flux-operator/) directories contain the reusable parts of the Flux bootstrap. Cluster bootstrap overlays compose them with environment-specific sync settings and operator values. These components are applied manually and are deliberately excluded from [`infra/kustomization.yaml`](infra/kustomization.yaml) because Flux cannot reconcile its own initial installation.

### Helm sources and releases

A `HelmRepository` and the `HelmRelease` that uses it are related, but they belong to different reconciliation boundaries:

- [`infra/kustomization.yaml`](infra/kustomization.yaml) collects chart sources and assigns them to the `flux` namespace. The `sources` Flux Kustomization reconciles these resources.
- Each installable infrastructure component exposes its `HelmRelease` through a component Kustomization. An environment overlay includes that component, assigns its workload namespace, and applies environment-specific values or patches.
- The workload's Flux Kustomization uses `dependsOn` to wait for `sources`. Resource order and file layout do not provide this ordering.

For example, Dex's [`source.yaml`](infra/dex/source.yaml) creates `HelmRepository/dex` in `flux`, while [`helm-release.yaml`](infra/dex/helm-release.yaml) is included by the [local Dex overlay](../../live/local/namespaces/dex/) and creates `HelmRelease/dex` in the `dex` namespace. The release explicitly references the source in `flux`.

The resources remain in separate files so each Kustomize entry point can select only the resource it owns. A YAML file may contain multiple documents, but referencing that file from Kustomize imports every document; Kustomize cannot select one document from the file. Combining the source and release would therefore pull the source into the workload overlay or the release into the shared source reconciliation, giving them the wrong namespace, ownership, or environment-specific customization.
