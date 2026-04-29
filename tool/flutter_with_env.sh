#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: ./tool/flutter_with_env.sh <dev|staging|prod> <flutter args...>"
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
define_file="$repo_root/tool/dart_defines/$environment.json"

if [[ ! -f "$define_file" ]]; then
  echo "Missing dart define file: $define_file"
  exit 1
fi

"$repo_root/tool/use_firebase_environment.sh" "$environment" >/dev/null

flutter_args=("$@")

if [[ ${#flutter_args[@]} -ge 2 && "${flutter_args[0]}" == "build" ]]; then
  case "${flutter_args[1]}" in
    apk|appbundle|ipa|ios|macos)
      has_flavor=0
      for arg in "${flutter_args[@]}"; do
        if [[ "$arg" == "--flavor" || "$arg" == --flavor=* ]]; then
          has_flavor=1
          break
        fi
      done

      if [[ $has_flavor -eq 0 ]]; then
        flutter_args+=("--flavor" "$environment")
      fi
      ;;
  esac
fi

exec flutter "${flutter_args[@]}" --dart-define-from-file="$define_file"
