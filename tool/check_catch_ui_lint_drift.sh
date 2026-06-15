#!/usr/bin/env bash
#
# Catch UI lint drift helper.
#
# Replaces the retired design-token scanner count mode for the migrated
# color/text-style/font rules. Enforcement lives in dart analyze; this script
# is only the aggregate reporting layer.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash tool/check_catch_ui_lint_drift.sh [--summary|--count|--json [PATH]|--code CODE|--label LABEL|--all|--help]

Modes:
  default    Print summary plus matching diagnostics. Exit 1 if drift remains.
  --summary  Print summary only. Exit 1 if drift remains.
  --count    Print only the numeric drift count. Always exit 0.
  --json     Print a JSON count artifact. Optionally also write it to PATH. Always exit 0.
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
JSON_PATH=""

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
    --json)
      MODE="json"
      if [ $# -gt 1 ] && [[ "$2" != --* ]]; then
        JSON_PATH="$2"
        shift 2
      else
        shift
      fi
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
analyze_output="$(dart analyze 2>&1)"
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

json_escape() {
  sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' <<<"$1"
}

if [ "$MODE" = "json" ]; then
  json_tmp="$(mktemp "${TMPDIR:-/tmp}/catch-ui-lint-drift-json.XXXXXX")"
  {
    echo "{"
    printf '  "label": "%s",\n' "$(json_escape "$LABEL")"
    printf '  "codeRegex": "%s",\n' "$(json_escape "$CODE_REGEX")"
    printf '  "analyzeStatus": %s,\n' "$analyze_status"
    if [ "$analyze_status" -eq 0 ]; then
      echo '  "complete": true,'
    else
      echo '  "complete": false,'
    fi
    printf '  "total": %s,\n' "$total"
    echo '  "counts": {'
    awk '
      {
        while (match($0, /catch_[a-z0-9_]+/)) {
          code = substr($0, RSTART, RLENGTH)
          counts[code] += 1
          $0 = substr($0, RSTART + RLENGTH)
        }
      }
      END {
        for (code in counts) print code "\t" counts[code]
      }
    ' "$tmp" | sort | awk '
      BEGIN { first = 1 }
      {
        if (!first) printf ",\n"
        first = 0
        printf "    \"%s\": %d", $1, $2
      }
      END {
        if (!first) printf "\n"
      }
    '
    echo '  }'
    echo "}"
  } >"$json_tmp"

  if [ -n "$JSON_PATH" ]; then
    cat "$json_tmp" >"$JSON_PATH"
  fi
  cat "$json_tmp"
  rm -f "$json_tmp"
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

if [ "$analyze_status" -ne 0 ] &&
  grep -Eq '(^|[[:space:]])(error|fatal) - ' <<<"$analyze_output"; then
  echo ""
  echo "dart analyze failed with errors outside $LABEL drift. Output:"
  echo "$analyze_output"
  exit "$analyze_status"
fi

echo "No migrated Catch UI lint drift found."
