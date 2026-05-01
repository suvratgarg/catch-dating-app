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

has_flavor=0
for arg in "${flutter_args[@]}"; do
  if [[ "$arg" == "--flavor" || "$arg" == --flavor=* ]]; then
    has_flavor=1
    break
  fi
done

if [[ ${#flutter_args[@]} -ge 2 && "${flutter_args[0]}" == "build" ]]; then
  case "${flutter_args[1]}" in
    apk|appbundle|ipa|ios|macos)
      if [[ $has_flavor -eq 0 ]]; then
        flutter_args+=("--flavor" "$environment")
      fi
      ;;
  esac
elif [[ ${#flutter_args[@]} -ge 1 && "${flutter_args[0]}" == "run" && $has_flavor -eq 0 ]]; then
  target_device=""
  for ((i = 0; i < ${#flutter_args[@]}; i++)); do
    case "${flutter_args[$i]}" in
      -d|--device-id)
        if (( i + 1 < ${#flutter_args[@]} )); then
          target_device="${flutter_args[$((i + 1))]}"
        fi
        ;;
      --device-id=*)
        target_device="${flutter_args[$i]#--device-id=}"
        ;;
    esac
  done

  case "$target_device" in
    chrome|edge|web-server)
      ;;
    *)
      flutter_args+=("--flavor" "$environment")
      ;;
  esac
fi

extra_dart_defines=()
if [[ -n "${FIREBASE_APP_CHECK_DEBUG_TOKEN:-}" ]]; then
  extra_dart_defines+=(
    "--dart-define=FIREBASE_APP_CHECK_DEBUG_TOKEN=${FIREBASE_APP_CHECK_DEBUG_TOKEN}"
  )
fi

if [[ ${#extra_dart_defines[@]} -gt 0 ]]; then
  exec flutter "${flutter_args[@]}" \
    --dart-define-from-file="$define_file" \
    "${extra_dart_defines[@]}"
fi

exec flutter "${flutter_args[@]}" --dart-define-from-file="$define_file"
