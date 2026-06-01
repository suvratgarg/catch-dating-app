#!/usr/bin/env bash
#
# Analyzer-backed UI-system raw-value report.
#
# The deterministic UI-system policy now lives in packages/catch_ui_lints. This
# wrapper keeps the historical command name while retiring the old shell regex
# scanner.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash tool/check_ui_system_raw_values.sh [--summary|--count|--help]

Modes:
  default    Print summary plus every migrated UI-system diagnostic. Exit 1 if targets remain.
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

codes="catch_no_raw_ui_spacing|catch_no_token_arithmetic|catch_prefer_semantic_insets|catch_no_raw_material_control|catch_no_raw_button_control|catch_no_raw_radius|catch_no_raw_icon_source|catch_no_raw_icon_size|catch_no_raw_alpha|catch_no_raw_shadow|catch_no_raw_motion|catch_no_raw_breakpoint|catch_no_raw_surface_shell"

cd "$(dirname "${BASH_SOURCE[0]}")/.."
exec bash tool/check_catch_ui_lint_drift.sh \
  --code "$codes" \
  --label "UI-system raw values" \
  "${mode_args[@]}"
