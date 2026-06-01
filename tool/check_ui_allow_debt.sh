#!/usr/bin/env bash
#
# Analyzer-backed UI allow-debt report.
#
# Temporary Catch UI allow comments are enforced by packages/catch_ui_lints as
# catch_no_allow_debt. This wrapper keeps the historical entry point while
# retiring the old ripgrep scanner.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash tool/check_ui_allow_debt.sh [--summary|--count|--help]

Modes:
  default    Print summary plus every allow-debt diagnostic. Exit 1 if markers remain.
  --summary  Print summary only. Exit 1 if markers remain.
  --count    Print only the numeric marker count. Always exit 0.
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
  --code "catch_no_allow_debt" \
  --label "UI allow debt" \
  "${mode_args[@]}"
