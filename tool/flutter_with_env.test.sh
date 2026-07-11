#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stub_dir="$(mktemp -d)"
trap 'rm -rf "$stub_dir"' EXIT

printf '%s\n' \
  '#!/usr/bin/env bash' \
  'printf "lib/main_host_prod.dart\thost-prod\thostProd\n"' \
  >"$stub_dir/node"
chmod +x "$stub_dir/node"

expect_rejected() {
  local expected="$1"
  shift
  local output
  if output="$(PATH="$stub_dir:$PATH" bash "$repo_root/tool/flutter_with_env.sh" "$@" 2>&1)"; then
    echo "Expected command to reject mismatched app-target arguments: $*" >&2
    exit 1
  fi
  if [[ "$output" != *"$expected"* ]]; then
    echo "Expected rejection containing '$expected', got:" >&2
    echo "$output" >&2
    exit 1
  fi
}

expect_rejected \
  "resolves flavor 'host-prod'; caller supplied 'prod'" \
  prod --role host build ios --flavor prod
expect_rejected \
  "resolves entrypoint 'lib/main_host_prod.dart'; caller supplied 'lib/main_consumer_prod.dart'" \
  prod --role host build ios -t lib/main_consumer_prod.dart

echo "flutter_with_env app-target argument checks passed."
