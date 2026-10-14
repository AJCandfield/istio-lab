# Application components

This directory is the reusable application layer of the manifest tree. Each application—[frontend](frontend/), [orders](orders/), and [payments](payments/)—is a namespace-neutral Kustomize component containing its Deployment and Service.

Environment overlays choose which components to deploy and provide environment-specific placement. The local environment composes all three applications in the [`main` namespace overlay](../../../live/local/namespaces/main/).
