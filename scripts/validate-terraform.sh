#!/usr/bin/env bash
set -euo pipefail

terraform fmt -check -recursive infra/modules
terragrunt hcl format --check --working-dir infra/live

if [ -n "${SOPS_AGE_KEY_FILE:-}" ] && [ -f "$SOPS_AGE_KEY_FILE" ]; then
  terragrunt hcl validate --inputs --strict --working-dir infra/live --tf-path terraform
else
  printf 'skipping Terragrunt input validation without SOPS_AGE_KEY_FILE\n'
fi

for module in infra/modules/*; do
  [ -d "$module" ] || continue
  terraform -chdir="$module" init -backend=false -input=false >/dev/null
  terraform -chdir="$module" validate
done
