#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <environment> <comma-separated-targets> [firebase deploy args...]" >&2
  exit 64
fi

environment="$1"
targets_csv="$2"
shift 2

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
  if ! contains_target "$target" "${selected_targets[@]}"; then
    selected_targets+=("$target")
  fi
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
    functions|firestore:indexes|firestore:rules|storage|hosting)
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

  echo "::group::Deploy Firebase target: $target"
  ./tool/firebase_with_env.sh "$environment" deploy --only "$target" --non-interactive "$@"
  echo "::endgroup::"
}

safe_order=(functions firestore:indexes firestore:rules storage hosting)
for target in "${safe_order[@]}"; do
  if contains_target "$target" "${selected_targets[@]}"; then
    deploy_target "$target" "$@"
  fi
done

for target in "${extra_targets[@]}"; do
  deploy_target "$target" "$@"
done
