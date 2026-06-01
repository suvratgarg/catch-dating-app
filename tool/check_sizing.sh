#!/usr/bin/env bash
#
# Analyzer-backed sizing-doctrine report.
#
# The hardcoded-dimension policy now lives in packages/catch_ui_lints as
# catch_no_raw_content_dimension. This wrapper keeps the historical CI/doc entry
# point while retiring the old shell regex scanner.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash tool/check_sizing.sh [--summary|--count|--help]

Modes:
  default    Print summary plus every hardcoded-dimension diagnostic. Exit 1 if candidates remain.
  --summary  Print only the candidate count and doctrine pointer. Exit 1 if candidates remain.
  --count    Print only the numeric candidate count. Always exit 0.
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
  --code "catch_no_raw_content_dimension" \
  --label "sizing doctrine" \
  "${mode_args[@]}"
