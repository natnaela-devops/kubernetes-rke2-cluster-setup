#!/usr/bin/env bash
set -euo pipefail

required=(helm kubeconform shellcheck yamllint)
missing=()

for command in "${required[@]}"; do
  if ! command -v "$command" >/dev/null 2>&1; then
    missing+=("$command")
  fi
done

if ((${#missing[@]} > 0)); then
  printf 'Missing validation tools: %s\n' "${missing[*]}" >&2
  printf 'Install them or run the GitHub Actions validation workflow.\n' >&2
  exit 2
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
rendered="$(mktemp --suffix=.yaml)"
trap 'rm -f "$rendered"' EXIT

cd "$repo_root"

yamllint \
  config \
  manifests \
  charts/platform-demo/Chart.yaml \
  charts/platform-demo/values.yaml \
  .github/workflows/validate.yml

shellcheck scripts/*.sh
helm lint charts/platform-demo
helm template platform-demo charts/platform-demo --namespace platform-demo >"$rendered"

kubeconform \
  -strict \
  -summary \
  -ignore-missing-schemas \
  manifests/longhorn "$rendered"

printf 'All repository validation checks passed.\n'
