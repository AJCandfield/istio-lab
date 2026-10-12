# Bootstrap resources

This directory contains the operator-owned resources needed to establish Flux on the local cluster, including its namespace, operator values, encrypted Git credentials, and Flux instance. These resources must exist before GitOps can reconcile the rest of the environment.

Bootstrap resources are intentionally excluded from the [local root Kustomization](../kustomization.yaml) because Flux cannot own its own initial setup. Follow the [root bootstrap instructions](../../../README.md#bootstrap) to apply them in the required order.
