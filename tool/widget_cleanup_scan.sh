#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

max_lines="${WIDGET_CLEANUP_SCAN_MAX_LINES:-80}"

scan() {
  local title="$1"
  local pattern="$2"
  shift 2

  echo
  echo "==> $title"
  local output
  output="$(rg -n \
    --glob '!**/*.g.dart' \
    --glob '!**/*.freezed.dart' \
    --glob '!**/*_controller.dart' \
    --glob '!**/*_notifier.dart' \
    --glob '!**/data/**' \
    --glob '!lib/core/theme/catch_spacing.dart' \
    --glob '!build/**' \
    "$pattern" "$@" | sort -u || true)"
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

scan "Brittle widget-test timing and missed-tap patterns" \
  'pumpAndSettle\(|pump\(const Duration|Future<void>\.delayed|warnIfMissed: false' \
  test

scan "Brittle positional widget finders" \
  'find\.[A-Za-z]+\([^)]*\)\.(at|first|last)|Scrollable\.first|ListView\.first' \
  test

scan "Presentation widgets reaching directly into repository providers" \
  'ref\.(read|watch)\([^)]*RepositoryProvider' \
  lib

scan "Feature widgets prop-drilling CatchTokens" \
  'final CatchTokens tokens|required this\.tokens|this\.tokens' \
  lib

scan "Custom tappables that may need semantic keys/tooltips" \
  'GestureDetector\(|InkWell\(|IconButton\(|TextButton\(' \
  lib

scan "Legacy spacing compatibility helpers" \
  'Sizes\.p[0-9]+' \
  lib test

scan "Plugin/platform side effects inside presentation code" \
  "import 'package:(url_launcher|connectivity_plus|firebase_messaging|image_picker|share_plus)" \
  lib/main.dart lib/core/presentation lib/*/presentation
