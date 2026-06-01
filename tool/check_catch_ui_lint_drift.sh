#!/usr/bin/env bash
#
# Catch UI lint drift helper.
#
# Replaces the retired design-token scanner count mode for the migrated
# color/text-style/font rules. Enforcement lives in flutter analyze; this script
# is only the aggregate reporting layer.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash tool/check_catch_ui_lint_drift.sh [--summary|--count|--code CODE|--label LABEL|--all|--help]

Modes:
  default    Print summary plus matching diagnostics. Exit 1 if drift remains.
  --summary  Print summary only. Exit 1 if drift remains.
  --count    Print only the numeric drift count. Always exit 0.
  --code     Count one Catch UI lint code.
  --label    Human-readable label for summary output.
  --all      Count all Catch UI lint codes.

Counts:
  Default: catch_no_raw_color, catch_no_raw_text_style, catch_no_raw_font_drift.
EOF
}

MODE="default"
CODE_REGEX="catch_no_raw_color|catch_no_raw_text_style|catch_no_raw_font_drift"
LABEL="color/text/font"

while [ $# -gt 0 ]; do
  case "$1" in
    --summary)
      MODE="summary"
      shift
      ;;
    --count)
      MODE="count"
      shift
      ;;
    --code)
      if [ $# -lt 2 ]; then
        usage >&2
        exit 2
      fi
      CODE_REGEX="$2"
      LABEL="$2"
      shift 2
      ;;
    --label)
      if [ $# -lt 2 ]; then
        usage >&2
        exit 2
      fi
      LABEL="$2"
      shift 2
      ;;
    --all)
      CODE_REGEX="catch_[a-z0-9_]+"
      LABEL="all Catch UI lints"
      shift
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
done

cd "$(dirname "${BASH_SOURCE[0]}")/.."

set +e
analyze_output="$(flutter analyze --no-fatal-infos 2>&1)"
analyze_status=$?
set -e

tmp="$(mktemp "${TMPDIR:-/tmp}/catch-ui-lint-drift.XXXXXX")"
trap 'rm -f "$tmp"' EXIT

awk -v code_regex="$CODE_REGEX" '
  $0 ~ code_regex {
    print
  }
' <<<"$analyze_output" >"$tmp"

if [ -s "$tmp" ]; then
  total="$(wc -l <"$tmp" | tr -d ' ')"
else
  total=0
fi

if [ "$MODE" = "count" ]; then
  echo "$total"
  exit 0
fi

echo "Catch UI lint drift ($LABEL): $total"

if [ "$total" -gt 0 ]; then
  echo ""
  echo "By code:"
  awk '
    {
      while (match($0, /catch_[a-z0-9_]+/)) {
        code = substr($0, RSTART, RLENGTH)
        counts[code] += 1
        $0 = substr($0, RSTART + RLENGTH)
      }
    }
    END {
      for (code in counts) print counts[code] "\t" code
    }
  ' "$tmp" | sort -rn

  if [ "$MODE" != "summary" ]; then
    echo ""
    echo "Findings:"
    cat "$tmp"
  fi

  echo ""
  echo "Route these findings through the documented Catch semantic primitives."
  exit 1
fi

if [ "$analyze_status" -ne 0 ]; then
  echo ""
  echo "flutter analyze failed without migrated color/text/font drift. Output:"
  echo "$analyze_output"
  exit "$analyze_status"
fi

echo "No migrated Catch UI lint drift found."
