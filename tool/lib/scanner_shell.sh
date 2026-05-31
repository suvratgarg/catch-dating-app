#!/usr/bin/env bash
#
# Shared shell helpers for stable root-level scanner wrappers.

scanner_cd_repo_root() {
  local script_path="${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}"
  local script_dir
  script_dir="$(cd "$(dirname "$script_path")" && pwd)"
  SCANNER_REPO_ROOT="$(cd "$script_dir/.." && pwd)"
  cd "$SCANNER_REPO_ROOT"
}

scanner_parse_mode() {
  MODE="full"
  case "${1:-}" in
    --summary) MODE="summary" ;;
    --count) MODE="count" ;;
    --help | -h) usage; exit 0 ;;
    "") ;;
    *) usage >&2; exit 2 ;;
  esac
}

scanner_require_command() {
  local command_name="$1"
  local display_name="${2:-$command_name}"
  command -v "$command_name" >/dev/null 2>&1 || {
    echo "$display_name is required but was not found on PATH." >&2
    exit 2
  }
}
