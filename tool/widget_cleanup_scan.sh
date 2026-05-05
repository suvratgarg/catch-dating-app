#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

max_lines="${WIDGET_CLEANUP_SCAN_MAX_LINES:-80}"

common_globs=(
  --glob '!**/*.g.dart'
  --glob '!**/*.freezed.dart'
  --glob '!**/*_controller.dart'
  --glob '!**/*_notifier.dart'
  --glob '!**/data/**'
  --glob '!lib/core/theme/catch_spacing.dart'
  --glob '!build/**'
)

scan() {
  local title="$1"
  local pattern="$2"
  shift 2

  echo
  echo "==> $title"
  local output
  output="$(rg -n \
    "${common_globs[@]}" \
    "$pattern" "$@" | sort -t: -k1,1 -k2,2n -u || true)"
  if [[ -z "$output" ]]; then
    echo "No matches."
    return
  fi

  local count
  count="$(printf '%s\n' "$output" | wc -l | tr -d ' ')"
  echo "$count match(es). Showing first $max_lines:"
  printf '%s\n' "$output" | sed -n "1,${max_lines}p"
}

scan_tappables() {
  echo
  echo "==> Feature tappables that may need semantic keys/tooltips"
  local raw
  raw="$(rg -n \
    "${common_globs[@]}" \
    'GestureDetector\(|InkWell\(|IconButton\(|TextButton\(' \
    lib/*/presentation | sort -t: -k1,1 -k2,2n -u || true)"

  local output=""
  while IFS=: read -r file line _; do
    [[ -z "$file" || -z "$line" ]] && continue
    local start=$((line > 8 ? line - 8 : 1))
    local end=$((line + 20))
    local context
    context="$(sed -n "${start},${end}p" "$file")"

    # The scan is looking for unresolved custom tap targets. Built-in text
    # buttons, icon buttons with tooltips, and tappables already wrapped in
    # Semantics/Tooltip are considered reviewed for this triage pass.
    if grep -Eq 'Semantics\(|Tooltip\(|tooltip:' <<<"$context"; then
      continue
    fi
    if grep -Eq 'TextButton\(' <<<"$(sed -n "${line}p" "$file")" &&
      grep -Eq 'child: (const )?Text\(' <<<"$context"; then
      continue
    fi

    output+="${file}:${line}:$(sed -n "${line}p" "$file")"$'\n'
  done <<<"$raw"

  output="$(printf '%s\n' "$output" | sed '/^$/d' || true)"
  if [[ -z "$output" ]]; then
    echo "No matches."
    return
  fi

  local count
  count="$(printf '%s\n' "$output" | wc -l | tr -d ' ')"
  echo "$count match(es). Showing first $max_lines:"
  printf '%s\n' "$output" | sed -n "1,${max_lines}p"
}

echo "Widget cleanup candidate scan"
echo "This is a triage aid, not a failing lint. Review matches before editing."
echo "Limit output with WIDGET_CLEANUP_SCAN_MAX_LINES=<n>."

scan "Brittle widget-test timing and missed-tap patterns" \
  'pumpAndSettle\(|pump\(const Duration|warnIfMissed: false' \
  test

scan "Async unit-test flush candidates" \
  'Future<void>\.delayed\(Duration\.zero\)' \
  test

scan "Brittle positional widget finders" \
  'find\.[A-Za-z]+\([^)]*\)\.(at|first|last)|Scrollable\.first|ListView\.first' \
  test

scan "Presentation widgets reaching directly into repository providers" \
  'ref\.(read|watch)\([^)]*RepositoryProvider' \
  lib/core/presentation lib/*/presentation

scan "Feature widgets prop-drilling CatchTokens" \
  'final CatchTokens tokens|required this\.tokens|this\.tokens' \
  lib

scan_tappables

scan "Legacy 4-point spacing migration candidates" \
  'Sizes\.p(4|8|12|16|20|24|32|40|48|64)\b' \
  lib test

scan "Fine-grained spacing compatibility helpers" \
  'Sizes\.p(2|3|6|10|14|18)\b' \
  lib test

scan "Plugin/platform side effects inside presentation code" \
  "import 'package:(url_launcher|connectivity_plus|firebase_messaging|image_picker|share_plus)" \
  lib/main.dart lib/core/presentation lib/*/presentation
