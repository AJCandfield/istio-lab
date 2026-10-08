debug-curl-up:
    kubectl apply -f manifests/debug-curl.yaml
    kubectl rollout status deployment/debug-curl --namespace istio-lab

debug-curl-down:
    kubectl delete -f manifests/debug-curl.yaml --ignore-not-found
