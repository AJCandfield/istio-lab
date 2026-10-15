# Dex

This component provides the Dex Helm source and release. Environment overlays supply the namespace, values, persistence, network policy, and identity configuration.

## Local test user

The local environment declares `test@istio-lab.localhost` as a static Dex user in the SOPS-encrypted bootstrap configuration. Its generated password is stored in the applied `dex-config` Secret and can be read when needed:

```sh
kubectl --namespace dex get secret dex-config \
  --output=jsonpath='{.data.password}' | base64 --decode
printf '\n'
```

Sign in at `http://flux.localhost:8080` with that email and password. The local [`flux-web-test-user` ClusterRoleBinding](../../../../live/local/namespaces/dex/test-user-rbac.yaml) grants this identity the `flux-web-admin` role. This account and binding are for the loopback-only local environment and must not be copied to shared environments.

## Managing users declaratively

Dex static users are read-only configuration. When `staticPasswords` is present, Dex uses that list instead of password records in its storage, so additions, password changes, and removals should be made in [`config.sops.yaml`](../../../../live/local/_bootstrap/dex/config.sops.yaml).

Generate a unique user ID and bcrypt password hash without recording the plaintext password in Git:

```sh
uuidgen | tr '[:upper:]' '[:lower:]'
read -s password
printf '\n'
htpasswd -bnBC 12 user "$password" | cut -d: -f2
unset password
```

Edit the encrypted Secret with SOPS and add the user under `staticPasswords` in its embedded `config.yaml`:

```sh
SOPS_AGE_KEY_FILE="$HOME/.config/mise/istio-lab-age.txt" \
  sops live/local/_bootstrap/dex/config.sops.yaml
```

Each entry requires a unique email, username, user ID, and bcrypt hash. Keep the plaintext password in an appropriate credential store. The `stringData.password` field is reserved for the included test user's generated password.

To authorize the identity in Flux, add a local RBAC binding whose user subject exactly matches the Dex email. Use `flux-web-user` for read-only access or `flux-web-admin` for Flux actions. Authentication can succeed without a binding, but Kubernetes RBAC will deny access to resources.

After changing the encrypted configuration, apply it and restart Dex because Dex reads static users at startup:

```sh
SOPS_AGE_KEY_FILE="$HOME/.config/mise/istio-lab-age.txt" \
  sops decrypt live/local/_bootstrap/dex/config.sops.yaml | kubectl apply -f -
kubectl --namespace dex rollout restart deployment/dex
kubectl --namespace dex rollout status deployment/dex
```

To remove a user, delete its `staticPasswords` entry and RBAC binding, reapply the Secret, and restart Dex.
