debug-curl-up:
    kubectl apply -f manifests/debug-curl.yaml
    kubectl rollout status deployment/debug-curl --namespace istio-lab
    kubectl exec --stdin --tty --namespace istio-lab --container debug-tools deployment/debug-curl -- /bin/sh

debug-curl-down:
    kubectl delete -f manifests/debug-curl.yaml --ignore-not-found
