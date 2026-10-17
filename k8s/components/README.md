# Application components

This directory contains reusable, environment-neutral application manifests. Each application owns its Deployment and Service, and the root [`apps/kustomization.yaml`](apps/kustomization.yaml) composes the complete application set.

The local overlay in [`live/local/apps`](../../live/local/apps/) assigns these resources to the Terraform-managed `main` namespace. Flux reconciles that overlay and does not own platform infrastructure.
