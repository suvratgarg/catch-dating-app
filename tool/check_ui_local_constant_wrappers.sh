#!/usr/bin/env bash
#
# Analyzer-backed UI local-constant wrapper report.
#
# Private feature UI constants are enforced by packages/catch_ui_lints as
# catch_no_local_design_constant. This wrapper keeps the historical entry point
# while retiring the old shell regex scanner.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash tool/check_ui_local_constant_wrappers.sh [--summary|--count|--help]

Modes:
  default    Print summary plus every local raw design constant diagnostic. Exit 1 if targets remain.
  --summary  Print summary only. Exit 1 if targets remain.
  --count    Print only the numeric target count. Always exit 0.
EOF
}

mode_args=()
case "${1:-}" in
  "")
    ;;
  --summary)
    mode_args+=(--summary)
    ;;
  --count)
    mode_args+=(--count)
    ;;
  --help|-h)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

cd "$(dirname "${BASH_SOURCE[0]}")/.."
exec bash tool/check_catch_ui_lint_drift.sh \
  --code "catch_no_local_design_constant" \
  --label "local design constants" \
  "${mode_args[@]}"
