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
    'GestureDetector\(|InkWell\(|IconButton\(|(^|[^A-Za-z])TextButton\(' \
    lib/*/presentation | sort -t: -k1,1 -k2,2n -u || true)"

  local output=""
  while IFS=: read -r file line _; do
    [[ -z "$file" || -z "$line" ]] && continue
    local start=$((line > 20 ? line - 20 : 1))
    local end=$((line + 20))
    local context
    context="$(sed -n "${start},${end}p" "$file")"
    local line_text
    line_text="$(sed -n "${line}p" "$file")"

    # The scan is looking for unresolved custom tap targets. Built-in text
    # buttons, icon buttons with tooltips, and tappables already wrapped in
    # Semantics/Tooltip are considered reviewed for this triage pass.
    if grep -Eq 'Semantics\(|Tooltip\(|tooltip:' <<<"$context"; then
      continue
    fi
    if grep -Eq '(^|[^A-Za-z])TextButton\(' <<<"$(sed -n "${line}p" "$file")" &&
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

scan_white_pill_ctas() {
  echo
  echo "==> Fixed-white pill CTA candidates that should use CatchButtonVariant.light"
  local raw
  raw="$(rg -n \
    "${common_globs[@]}" \
    'backgroundColor: Colors\.white\b|color: Colors\.white\b' \
    lib/core lib/*/presentation | sort -t: -k1,1 -k2,2n -u || true)"

  local output=""
  while IFS=: read -r file line _; do
    [[ -z "$file" || -z "$line" ]] && continue
    local start=$((line > 14 ? line - 14 : 1))
    local end=$((line + 18))
    local context
    context="$(sed -n "${start},${end}p" "$file")"
    local line_text
    line_text="$(sed -n "${line}p" "$file")"

    # Solid white CatchButton overrides should use the light variant so the
    # foreground stays fixed to the light palette instead of ambient dark-mode
    # text tokens.
    if grep -Eq 'CatchButton\(' <<<"$context" &&
      grep -Eq 'backgroundColor: Colors\.white,' <<<"$context"; then
      output+="${file}:${line}:${line_text}"$'\n'
      continue
    fi

    # Button-looking white pills inside tappable cards should still use the
    # button primitive in non-interactive display mode.
    if grep -Eq 'color: Colors\.white,' <<<"$line_text" &&
      grep -Eq '(Container|DecoratedBox)\(' <<<"$context" &&
      grep -Eq 'Text\(' <<<"$context" &&
      grep -Eq 'alignment: Alignment\.center|height: (48|50|56),' <<<"$context" &&
      grep -Eq 'CatchRadius\.pill|BorderRadius\.circular' <<<"$context"; then
      output+="${file}:${line}:${line_text}"$'\n'
    fi
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

scan_raw_material_buttons() {
  echo
  echo "==> Raw Material/Cupertino button candidates that should use CatchButton or CatchTextButton"
  local output
  output="$(rg -n \
    "${common_globs[@]}" \
    '(^|[^A-Za-z])(ElevatedButton|OutlinedButton|FilledButton|TextButton|CupertinoButton|FloatingActionButton)\(' \
    lib/core lib/*/presentation \
    --glob '!lib/core/widgets/catch_adaptive_picker.dart' \
    --glob '!lib/core/widgets/catch_button.dart' \
    --glob '!lib/core/widgets/catch_text_button.dart' || true)"

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

scan_raw_text_inputs() {
  echo
  echo "==> Raw text input candidates that should use CatchTextField or a field-specific primitive"
  local output
  output="$(rg -n \
    "${common_globs[@]}" \
    '(^|[^A-Za-z])(TextField|TextFormField)\(' \
    lib/core lib/*/presentation \
    --glob '!lib/core/widgets/catch_text_field.dart' \
    --glob '!lib/core/widgets/catch_otp_code_field.dart' || true)"

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

scan_profile_bottom_sheet_editors() {
  echo
  echo "==> Profile field editors that still use bottom sheets"
  local output
  output="$(rg -n \
    "${common_globs[@]}" \
    'showModalBottomSheet|CatchBottomSheetScaffold' \
    lib/user_profile/presentation || true)"

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

scan_profile_inline_chip_labels() {
  echo
  echo "==> Profile inline chip editors that repeat the expanded tile label"
  local raw
  raw="$(rg -n --with-filename 'ChipField<' lib/user_profile/presentation/widgets/profile_inline_editors.dart || true)"

  local output=""
  while IFS=: read -r file line _; do
    [[ -z "$file" || -z "$line" ]] && continue
    local end=$((line + 12))
    local context
    context="$(sed -n "${line},${end}p" "$file")"
    if ! grep -Eq 'showLabel: false,' <<<"$context"; then
      output+="${file}:${line}:$(sed -n "${line}p" "$file")"$'\n'
    fi
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

scan_profile_inline_chip_clear_actions() {
  echo
  echo "==> Profile inline chip editors with separate Clear actions"
  local output
  output="$(rg -n --with-filename \
    "label: 'Clear'|label: \"Clear\"" \
    lib/user_profile/presentation/widgets/profile_inline_editors.dart || true)"

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

scan_profile_stacked_text_tile_editors() {
  echo
  echo "==> Profile text tile editors that stack a separate text field below the row"
  local raw
  raw="$(rg -n --with-filename --fixed-strings 'ProfileInfoEntry(' lib/user_profile/presentation/widgets/profile_tab.dart || true)"

  local output=""
  while IFS=: read -r file line _; do
    [[ -z "$file" || -z "$line" ]] && continue
    local end=$((line + 48))
    local context
    context="$(sed -n "${line},${end}p" "$file")"
    if grep -Fq 'ProfileInlineTextEditor(' <<<"$context"; then
      output+="${file}:${line}:$(sed -n "${line}p" "$file")"$'\n'
    fi
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

scan_profile_stacked_chip_tile_editors() {
  echo
  echo "==> Profile chip tile editors that stack selected chips below the row"
  local output
  output="$(rg -n --with-filename \
    'ProfileInline(Single|Multi)ChoiceEditor<' \
    lib/user_profile/presentation/widgets/profile_tab.dart || true)"

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

scan_raw_range_sliders() {
  echo
  echo "==> Raw range sliders that should use CatchRangeSlider"
  local output
  output="$(rg -n \
    "${common_globs[@]}" \
    '(^|[^A-Za-z])RangeSlider\(|SliderTheme\(' \
    lib/core lib/*/presentation \
    --glob '!lib/core/widgets/catch_range_slider.dart' || true)"

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

scan_raw_number_steppers() {
  echo
  echo "==> Raw +/- number steppers that should use CatchNumberStepper"
  local raw
  raw="$(rg -n \
    "${common_globs[@]}" \
    'Icons\.(add|remove)_rounded|Icons\.(add|remove)\b' \
    lib/core lib/*/presentation \
    --glob '!lib/core/widgets/catch_number_stepper.dart' || true)"

  local output=""
  while IFS=: read -r file line _; do
    [[ -z "$file" || -z "$line" ]] && continue
    local start=$((line > 24 ? line - 24 : 1))
    local end=$((line + 24))
    local context
    context="$(sed -n "${start},${end}p" "$file")"
    local line_text
    line_text="$(sed -n "${line}p" "$file")"

    # Flag feature-local increment/decrement controls, not standalone add
    # buttons like photo upload or FAB-style actions.
    if grep -Eq 'Icons\.(remove|remove_rounded)' <<<"$context" &&
      grep -Eq 'Icons\.(add|add_rounded)' <<<"$context" &&
      grep -Eq 'IconButton\(' <<<"$context" &&
      ! grep -Eq 'CatchNumberStepper\(' <<<"$context"; then
      output+="${file}:${line}:${line_text}"$'\n'
    fi
  done <<<"$raw"

  output="$(printf '%s\n' "$output" | sort -t: -k1,1 -k2,2n -u | sed '/^$/d' || true)"
  if [[ -z "$output" ]]; then
    echo "No matches."
    return
  fi

  local count
  count="$(printf '%s\n' "$output" | wc -l | tr -d ' ')"
  echo "$count match(es). Showing first $max_lines:"
  printf '%s\n' "$output" | sed -n "1,${max_lines}p"
}

scan_literal_sized_box_spacing() {
  echo
  echo "==> Literal SizedBox spacing candidates that should use gap constants or CatchSpacing"
  local output
  output="$(rg -n \
    "${common_globs[@]}" \
    'const SizedBox\((height|width): [0-9]' \
    lib/core lib/*/presentation || true)"

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

scan_raw_surface_containers() {
  echo
  echo "==> Feature-local decorated surface candidates that should consider CatchSurface"
  local raw
  raw="$(rg -n \
    "${common_globs[@]}" \
    'Container\(|DecoratedBox\(|AnimatedContainer\(' \
    lib/*/presentation || true)"

  local output=""
  while IFS=: read -r file line _; do
    [[ -z "$file" || -z "$line" ]] && continue
    local start=$((line > 2 ? line - 2 : 1))
    local end=$((line + 18))
    local context
    context="$(sed -n "${start},${end}p" "$file")"
    local line_text
    line_text="$(sed -n "${line}p" "$file")"

    # Layout-only containers and animation-only shells are often legitimate.
    # Flag local shells that own fill/border/radius/shadow decoration, because
    # those are the cases most likely to drift from CatchSurface/tokens.
    if grep -Eq 'decoration: BoxDecoration\(|color: CatchTokens|color: t\.|borderRadius:|Border\.all|boxShadow:' <<<"$context" &&
      ! grep -Eq 'CatchSurface\(' <<<"$context"; then
      output+="${file}:${line}:${line_text}"$'\n'
    fi
  done <<<"$raw"

  output="$(printf '%s\n' "$output" | sort -t: -k1,1 -k2,2n -u | sed '/^$/d' || true)"
  if [[ -z "$output" ]]; then
    echo "No matches."
    return
  fi

  local count
  count="$(printf '%s\n' "$output" | wc -l | tr -d ' ')"
  echo "$count match(es). Showing first $max_lines:"
  printf '%s\n' "$output" | sed -n "1,${max_lines}p"
}

scan_unstyled_text() {
  echo
  echo "==> App-facing Text candidates without nearby CatchTextStyles"
  local raw
  raw="$(rg -n \
    "${common_globs[@]}" \
    '(^|[^A-Za-z])Text\(' \
    lib/core/widgets lib/*/presentation \
    --glob '!lib/core/widgets/catch_adaptive_dialog.dart' \
    --glob '!lib/core/widgets/catch_button.dart' \
    --glob '!lib/core/widgets/catch_text_button.dart' || true)"

  local output=""
  while IFS=: read -r file line _; do
    [[ -z "$file" || -z "$line" ]] && continue
    local end=$((line + 6))
    local context
    context="$(sed -n "${line},${end}p" "$file")"
    local line_text
    line_text="$(sed -n "${line}p" "$file")"

    # Framework-owned labels in menus/snackbars/dialog titles may intentionally
    # inherit Material typography. Everything else should be reviewed for
    # CatchTextStyles so hard-coded or ambient dark-mode drift does not return.
    if grep -Eq 'CatchTextStyles\.|style:' <<<"$context"; then
      continue
    fi
    if grep -Eq 'SnackBar\(content: Text|PopupMenuItem.*child: Text|Badge\(label: Text|AlertDialog\(|title: Text\(' <<<"$context"; then
      continue
    fi
    output+="${file}:${line}:${line_text}"$'\n'
  done <<<"$raw"

  output="$(printf '%s\n' "$output" | sort -t: -k1,1 -k2,2n -u | sed '/^$/d' || true)"
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

scan_raw_material_buttons

scan_raw_text_inputs

scan_profile_bottom_sheet_editors

scan_profile_inline_chip_labels

scan_profile_inline_chip_clear_actions

scan_profile_stacked_text_tile_editors

scan_profile_stacked_chip_tile_editors

scan_white_pill_ctas

scan_raw_range_sliders

scan_raw_number_steppers

scan_tappables

scan_literal_sized_box_spacing

scan_raw_surface_containers

scan_unstyled_text

scan "Legacy 4-point spacing migration candidates" \
  'Sizes\.p(4|8|12|16|20|24|32|40|48|64)\b' \
  lib test

scan "Fine-grained spacing compatibility helpers" \
  'Sizes\.p(2|3|6|10|14|18)\b' \
  lib test

scan "Plugin/platform side effects inside presentation code" \
  "import 'package:(url_launcher|connectivity_plus|firebase_messaging|image_picker|share_plus)" \
  lib/main.dart lib/core/presentation lib/*/presentation

scan "Raw app-facing error surface migration candidates" \
  "CatchErrorText|Center\\(child: Text\\('[^']*(Unable|not found|failed|error|Error)|Scaffold\\(body: Center\\(child: Text\\('[^']*(Unable|not found|failed|error|Error)" \
  lib/*/presentation lib/core/widgets lib/routing
