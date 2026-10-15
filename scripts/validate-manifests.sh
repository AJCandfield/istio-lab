#!/usr/bin/env bash
set -euo pipefail

while IFS= read -r -d '' kustomization; do
  directory="${kustomization%/*}"
  kubectl kustomize "$directory" | kubeconform -strict -ignore-missing-schemas
  printf 'validated %s\n' "$directory"
done < <(find k8s live -name kustomization.yaml -type f -print0)

while IFS= read -r -d '' manifest; do
  kubeconform -strict -ignore-missing-schemas "$manifest"
  printf 'validated %s\n' "$manifest"
done < <(find infra/modules -path '*/manifests/*.yaml' -type f -print0)

while IFS= read -r -d '' secret; do
  sops filestatus "$secret" | grep -q '"encrypted":true'
  if ! awk '
    /^(data|stringData):$/ { payload = 1; next }
    /^[^ ]/ { payload = 0 }
    payload && /^    [[:alnum:]_.-]+:/ && $0 !~ /: ENC\[/ { invalid = 1 }
    END { exit invalid }
  ' "$secret"; then
    printf 'unencrypted Secret payload in %s\n' "$secret" >&2
    exit 1
  fi
  printf 'verified encryption for %s\n' "$secret"
done < <(find infra -name '*.sops.yaml' -type f -print0)
