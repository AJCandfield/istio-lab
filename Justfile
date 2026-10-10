kyverno-up:
    kubectl --context k3d-istio-lab apply -f helm/kyverno/namespace.yaml
    helmfile --file helm/kyverno/helmfile.yaml sync

debug-curl-up:
    kubectl apply -f manifests/debug-curl.yaml
    kubectl rollout status deployment/debug-curl --namespace istio-lab
    kubectl exec --stdin --tty --namespace istio-lab --container debug-tools deployment/debug-curl -- /bin/sh || [ "$?" -eq 130 ]

debug-curl-down:
    kubectl delete -f manifests/debug-curl.yaml --ignore-not-found
