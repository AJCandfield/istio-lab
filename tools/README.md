# Tools

This directory contains optional local utilities that are run imperatively and are not reconciled by Flux.

Create the debug container and open a shell:

```sh
kubectl --context k3d-istio-lab apply -f tools/debug-curl/deployment.yaml
kubectl --context k3d-istio-lab rollout status deployment/debug-curl --namespace main
kubectl --context k3d-istio-lab exec --stdin --tty --namespace main --container debug-tools deployment/debug-curl -- /bin/sh
```

Remove it when finished:

```sh
kubectl --context k3d-istio-lab delete -f tools/debug-curl/deployment.yaml --ignore-not-found
```
