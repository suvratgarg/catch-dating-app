#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <environment> <comma-separated-targets> [firebase deploy args...]" >&2
  exit 64
fi

environment="$1"
targets_csv="$2"
shift 2

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

selected_targets=()
extra_targets=()

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

contains_target() {
  local needle="$1"
  shift

  local item
  for item in "$@"; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done

  return 1
}

add_target() {
  local target="$1"
  if [[ ${#selected_targets[@]} -eq 0 ]] ||
    ! contains_target "$target" "${selected_targets[@]}"; then
    selected_targets+=("$target")
  fi
}

target_is_selected() {
  local target="$1"
  [[ ${#selected_targets[@]} -gt 0 ]] &&
    contains_target "$target" "${selected_targets[@]}"
}

IFS=',' read -ra requested_targets <<< "$targets_csv"
for raw_target in "${requested_targets[@]}"; do
  target="$(trim "$raw_target")"
  [[ -z "$target" ]] && continue

  case "$target" in
    all)
      add_target functions
      add_target firestore:indexes
      add_target firestore:rules
      add_target storage
      add_target hosting
      ;;
    firestore)
      add_target firestore:indexes
      add_target firestore:rules
      ;;
    functions|firestore:indexes|firestore:rules|storage|hosting|remoteconfig)
      add_target "$target"
      ;;
    *)
      extra_targets+=("$target")
      ;;
  esac
done

deploy_target() {
  local target="$1"
  shift
  local deploy_only="$target"

  if [[ "$target" == "functions" ]]; then
    deploy_only="$(
      node "$repo_root/tool/list_firebase_function_targets.mjs" --csv
    )"
  fi

  echo "::group::Deploy Firebase target: $target"
  "$repo_root/tool/firebase_with_env.sh" \
    "$environment" deploy --only "$deploy_only" --non-interactive "$@"
  echo "::endgroup::"
}

safe_order=(functions firestore:indexes firestore:rules storage hosting remoteconfig)
for target in "${safe_order[@]}"; do
  if target_is_selected "$target"; then
    deploy_target "$target" "$@"
  fi
done

if [[ ${#extra_targets[@]} -gt 0 ]]; then
  for target in "${extra_targets[@]}"; do
    deploy_target "$target" "$@"
  done
fi
