#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: ./tool/flutter_with_env.sh <dev|staging|prod> [--role <consumer|host>] <flutter args...>"
  exit 1
fi

environment="$1"
shift
app_role="${CATCH_APP_ROLE:-consumer}"

if [[ $# -ge 2 && "$1" == "--role" ]]; then
  app_role="$2"
  shift 2
elif [[ $# -ge 1 && ( "$1" == "consumer" || "$1" == "host" ) ]]; then
  app_role="$1"
  shift
fi

case "$environment" in
  dev|staging|prod) ;;
  *)
    echo "Unsupported environment: $environment"
    exit 1
    ;;
esac

case "$app_role" in
  consumer|host) ;;
  *)
    echo "Unsupported app role: $app_role"
    exit 1
    ;;
esac

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
define_file="$repo_root/tool/env/dart_defines/$environment.json"

if [[ ! -f "$define_file" ]]; then
  echo "Missing dart define file: $define_file"
  exit 1
fi

load_local_env_file() {
  local env_file="$1"
  [[ -f "$env_file" ]] || return 0

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    [[ -z "$line" || "$line" == \#* ]] && continue

    if [[ "$line" == export\ * ]]; then
      line="${line#export }"
    fi

    [[ "$line" == *=* ]] || continue

    local key="${line%%=*}"
    local value="${line#*=}"

    if [[ ! "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
      echo "Ignoring invalid env key '$key' in $env_file" >&2
      continue
    fi

    if [[ "$value" == \"*\" && "$value" == *\" && ${#value} -ge 2 ]]; then
      value="${value:1:${#value}-2}"
    elif [[ "$value" == \'*\' && ${#value} -ge 2 ]]; then
      value="${value:1:${#value}-2}"
    fi

    if [[ -z "${!key:-}" ]]; then
      export "$key=$value"
    fi
  done <"$env_file"
}

extract_target_device() {
  local i
  for ((i = 0; i < ${#flutter_args[@]}; i++)); do
    case "${flutter_args[$i]}" in
      -d|--device-id)
        if ((i + 1 < ${#flutter_args[@]})); then
          echo "${flutter_args[$((i + 1))]}"
          return 0
        fi
        ;;
      --device-id=*)
        echo "${flutter_args[$i]#--device-id=}"
        return 0
        ;;
    esac
  done
}

is_web_target() {
  case "$1" in
    chrome|edge|web-server) return 0 ;;
    *) return 1 ;;
  esac
}

is_ios_target() {
  case "$1" in
    *iPhone*|*iPad*|ios|IOS|0000*) return 0 ;;
    *) return 1 ;;
  esac
}

is_macos_target() {
  case "$1" in
    macos|macOS|darwin|Darwin) return 0 ;;
    *) return 1 ;;
  esac
}

is_android_target() {
  case "$1" in
    *android*|*Android*|emulator*) return 0 ;;
    *) return 1 ;;
  esac
}

load_local_env_file "$repo_root/.env.$environment.local"
load_local_env_file "$repo_root/.env.local"

export ORG_GRADLE_PROJECT_catchAppRole="$app_role"

flutter_args=("$@")
target_device="$(extract_target_device)"

native_flavor="$environment"
if [[ "$app_role" == "host" ]]; then
  if [[ ${#flutter_args[@]} -ge 2 && "${flutter_args[0]}" == "build" ]]; then
    case "${flutter_args[1]}" in
      ipa|ios|macos)
        native_flavor="host-$environment"
        ;;
    esac
  elif [[ ${#flutter_args[@]} -ge 1 && "${flutter_args[0]}" == "run" ]]; then
    if is_ios_target "$target_device" || is_macos_target "$target_device"; then
      native_flavor="host-$environment"
    fi
  fi
fi

"$repo_root/tool/use_firebase_environment.sh" "$environment" "$app_role" >/dev/null

has_flavor=0
has_target=0
for arg in "${flutter_args[@]}"; do
  if [[ "$arg" == "--flavor" || "$arg" == --flavor=* ]]; then
    has_flavor=1
  fi
  if [[ "$arg" == "-t" || "$arg" == "--target" || "$arg" == --target=* ]]; then
    has_target=1
  fi
done

if [[ $has_target -eq 0 && ${#flutter_args[@]} -ge 1 ]]; then
  case "${flutter_args[0]}" in
    run|build|drive)
      flutter_args+=("-t" "lib/main_${app_role}.dart")
      ;;
  esac
fi

if [[ ${#flutter_args[@]} -ge 2 && "${flutter_args[0]}" == "build" ]]; then
  case "${flutter_args[1]}" in
    apk|appbundle|ipa|ios|macos)
      if [[ $has_flavor -eq 0 ]]; then
        flutter_args+=("--flavor" "$native_flavor")
      fi
      ;;
  esac
elif [[ ${#flutter_args[@]} -ge 1 && "${flutter_args[0]}" == "run" && $has_flavor -eq 0 ]]; then
  if ! is_web_target "$target_device"; then
      flutter_args+=("--flavor" "$native_flavor")
  fi
fi

maps_platform=""
if [[ ${#flutter_args[@]} -ge 2 && "${flutter_args[0]}" == "build" ]]; then
  case "${flutter_args[1]}" in
    apk|appbundle)
      maps_platform="android"
      ;;
    ipa|ios)
      maps_platform="ios"
      ;;
  esac
elif [[ ${#flutter_args[@]} -ge 1 && "${flutter_args[0]}" == "run" ]]; then
  if is_web_target "$target_device"; then
    :
  elif is_ios_target "$target_device"; then
    maps_platform="ios"
  elif is_android_target "$target_device"; then
    maps_platform="android"
  else
    maps_platform="all"
  fi
fi

if [[ -n "$maps_platform" ]]; then
  node "$repo_root/tool/firebase/validate_google_maps_config.mjs" \
    --env "$environment" \
    --platform "$maps_platform"
fi

supports_dart_defines=0
if [[ ${#flutter_args[@]} -ge 1 ]]; then
  case "${flutter_args[0]}" in
    run|test|drive)
      supports_dart_defines=1
      ;;
    build)
      supports_dart_defines=1
      ;;
  esac
fi

is_debug_mobile_run=0
if [[ ${#flutter_args[@]} -ge 1 && "${flutter_args[0]}" == "run" ]]; then
  is_debug_mobile_run=1
  for arg in "${flutter_args[@]}"; do
    case "$arg" in
      --profile|--release)
        is_debug_mobile_run=0
        ;;
    esac
  done
  if is_web_target "$target_device"; then
    is_debug_mobile_run=0
  fi
fi

requires_debug_token=0
if [[ $is_debug_mobile_run -eq 1 ]]; then
  if [[ "${USE_FIREBASE_APP_CHECK_DEBUG_PROVIDER:-}" == "true" ]]; then
    requires_debug_token=1
  elif ! is_ios_target "$target_device"; then
    requires_debug_token=1
  fi
fi

if [[ $requires_debug_token -eq 1 &&
  -z "${FIREBASE_APP_CHECK_DEBUG_TOKEN:-}" &&
  "${ALLOW_RANDOM_APP_CHECK_DEBUG_TOKEN:-}" != "1" ]]; then
  cat >&2 <<EOF
Missing FIREBASE_APP_CHECK_DEBUG_TOKEN for a mobile debug run.

Firebase App Check enforcement rejects random debug tokens. Add a registered
debug token to .env.local, for example:

  FIREBASE_APP_CHECK_DEBUG_TOKEN=<registered-token>

If you are intentionally minting a one-time token for first setup, rerun with:

  ALLOW_RANDOM_APP_CHECK_DEBUG_TOKEN=1 ./tool/flutter_with_env.sh $environment ${flutter_args[*]}
EOF
  exit 1
fi

extra_dart_defines=()
extra_dart_defines+=("--dart-define=CATCH_APP_ROLE=${app_role}")
if [[ -n "${FIREBASE_APP_CHECK_DEBUG_TOKEN:-}" ]]; then
  extra_dart_defines+=(
    "--dart-define=FIREBASE_APP_CHECK_DEBUG_TOKEN=${FIREBASE_APP_CHECK_DEBUG_TOKEN}"
  )
fi
if [[ -n "${VERBOSE_AUTH_DEBUG_LOGS:-}" ]]; then
  extra_dart_defines+=(
    "--dart-define=VERBOSE_AUTH_DEBUG_LOGS=${VERBOSE_AUTH_DEBUG_LOGS}"
  )
fi
if [[ -n "${DISABLE_AUTH_APP_VERIFICATION_FOR_TESTING:-}" ]]; then
  extra_dart_defines+=(
    "--dart-define=DISABLE_AUTH_APP_VERIFICATION_FOR_TESTING=${DISABLE_AUTH_APP_VERIFICATION_FOR_TESTING}"
  )
fi
if [[ -n "${USE_FIREBASE_APP_CHECK_DEBUG_PROVIDER:-}" ]]; then
  extra_dart_defines+=(
    "--dart-define=USE_FIREBASE_APP_CHECK_DEBUG_PROVIDER=${USE_FIREBASE_APP_CHECK_DEBUG_PROVIDER}"
  )
fi
if [[ -n "${ENABLE_OBSERVABILITY_COLLECTION:-}" ]]; then
  extra_dart_defines+=(
    "--dart-define=ENABLE_OBSERVABILITY_COLLECTION=${ENABLE_OBSERVABILITY_COLLECTION}"
  )
fi
if [[ -n "${EMIT_OBSERVABILITY_SMOKE_EVENT:-}" ]]; then
  extra_dart_defines+=(
    "--dart-define=EMIT_OBSERVABILITY_SMOKE_EVENT=${EMIT_OBSERVABILITY_SMOKE_EVENT}"
  )
fi

if [[ $supports_dart_defines -eq 0 ]]; then
  exec flutter "${flutter_args[@]}"
fi

if [[ ${#extra_dart_defines[@]} -gt 0 ]]; then
  exec flutter "${flutter_args[@]}" \
    --dart-define-from-file="$define_file" \
    "${extra_dart_defines[@]}"
fi

exec flutter "${flutter_args[@]}" --dart-define-from-file="$define_file"
