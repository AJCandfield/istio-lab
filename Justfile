debug-curl-up:
    kubectl apply -f tools/debug-curl/deployment.yaml
    kubectl rollout status deployment/debug-curl --namespace istio-lab
    kubectl exec --stdin --tty --namespace istio-lab --container debug-tools deployment/debug-curl -- /bin/sh || [ "$?" -eq 130 ]

debug-curl-down:
    kubectl delete -f tools/debug-curl/deployment.yaml --ignore-not-found
