#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../.." && pwd)"

# shellcheck source=/dev/null
source "$repo_root/tool/ci/toolchain.env"

for name in FLUTTER_VERSION NODE_VERSION JAVA_VERSION FIREBASE_TOOLS_VERSION COCOAPODS_VERSION; do
  if [[ -z "${!name:-}" ]]; then
    echo "Missing $name in tool/ci/toolchain.env"
    exit 1
  fi
done

functions_node_version="$(node -p "require('$repo_root/functions/package.json').engines.node")"
if [[ "$functions_node_version" != "$NODE_VERSION" ]]; then
  echo "functions/package.json engines.node is $functions_node_version, but tool/ci/toolchain.env NODE_VERSION is $NODE_VERSION."
  exit 1
fi

echo "CI toolchain pins are consistent."
