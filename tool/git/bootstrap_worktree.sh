#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: bash tool/git/bootstrap_worktree.sh

Install the dependencies required by a fresh Catch Git worktree:
  1. root npm workspace dependencies
  2. Firebase Functions npm dependencies
  3. Flutter/Dart packages
USAGE
}

if [[ ${1:-} == "--help" || ${1:-} == "help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 0 ]]; then
  usage >&2
  exit 64
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(git -C "$script_dir/../.." rev-parse --show-toplevel)"

for required_path in package-lock.json functions/package-lock.json pubspec.yaml; do
  if [[ ! -f "$repo_root/$required_path" ]]; then
    echo "Worktree bootstrap requires $required_path." >&2
    exit 1
  fi
done

echo "==> Installing root npm workspace dependencies"
(
  cd "$repo_root"
  npm ci
)

echo "==> Installing Firebase Functions dependencies"
(
  cd "$repo_root/functions"
  npm ci
)

echo "==> Resolving Flutter dependencies"
(
  cd "$repo_root"
  flutter pub get
)

echo "Worktree bootstrap complete."
