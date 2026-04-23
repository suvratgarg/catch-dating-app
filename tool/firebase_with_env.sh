#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: ./tool/firebase_with_env.sh <dev|staging|prod> <firebase args...>"
  exit 1
fi

environment="$1"
shift

case "$environment" in
  dev|staging|prod) ;;
  *)
    echo "Unsupported environment: $environment"
    exit 1
    ;;
esac

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
firebaserc="$repo_root/.firebaserc"

if [[ ! -f "$firebaserc" ]] || ! grep -q "\"$environment\"" "$firebaserc"; then
  echo "Firebase alias '$environment' is not configured in .firebaserc."
  echo "Add it with: firebase use --add"
  exit 1
fi

exec firebase --project "$environment" "$@"
