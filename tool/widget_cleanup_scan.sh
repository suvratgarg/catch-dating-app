#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

max_lines="${WIDGET_CLEANUP_SCAN_MAX_LINES:-80}"

if [[ "${1:-}" == "--check" ]]; then
  summary="$(bash "$0" --summary)"
  printf '%s\n' "$summary"
  printf '%s\n' "$summary" | node tool/lib/widget_cleanup_ratchet.mjs \
    --baseline tool/audit/widget_cleanup_baseline.json
  exit 0
fi

if [[ "${1:-}" == "--summary" && "${WIDGET_CLEANUP_SCAN_FORCE_FULL:-}" != "1" ]]; then
  summary_key_for() {
    case "$1" in
      "Brittle widget-test timing and missed-tap patterns") echo "centralized_widget_timing" ;;
      "Async unit-test flush candidates") echo "async_unit_flush" ;;
      "Brittle positional widget finders") echo "positional_widget_finders" ;;
      "Presentation widgets reaching directly into repository providers") echo "presentation_repository_reaches" ;;
      "Feature widgets prop-drilling CatchTokens") echo "catch_tokens_prop_drilling" ;;
      "Raw Material/Cupertino button candidates that should use CatchButton or CatchTextButton") echo "raw_material_button_candidates" ;;
      "Raw text input candidates that should use CatchField.input or a field-specific primitive") echo "raw_text_input_candidates" ;;
      "Profile field editors that still use bottom sheets") echo "profile_bottom_sheet_editor_candidates" ;;
      "Profile inline chip editors that repeat the expanded tile label") echo "profile_inline_chip_label_candidates" ;;
      "Profile inline chip editors with separate Clear actions") echo "profile_inline_chip_clear_action_candidates" ;;
      "Profile text tile editors that stack a separate text field below the row") echo "profile_stacked_text_tile_editor_candidates" ;;
      "Profile chip tile editors that stack selected chips below the row") echo "profile_stacked_chip_tile_editor_candidates" ;;
      "Fixed-white pill CTA candidates that should use CatchButtonVariant.light") echo "fixed_white_pill_cta_candidates" ;;
      "Raw range sliders that should use CatchRangeSlider") echo "raw_range_slider_candidates" ;;
      "Raw +/- number steppers that should use CatchNumberStepper") echo "raw_number_stepper_candidates" ;;
      "Feature tappables that may need semantic keys/tooltips") echo "feature_tappable_candidates" ;;
      "Literal SizedBox spacing candidates that should use gap constants or CatchSpacing") echo "literal_sized_box_spacing_candidates" ;;
      "Feature-local decorated surface candidates that should consider CatchSurface") echo "raw_decorated_surface_candidates" ;;
      "App-facing Text candidates without nearby CatchTextStyles") echo "unstyled_text_candidates" ;;
      "App-facing low-level typography role candidates") echo "low_level_typography_role_candidates" ;;
      "Nonzero letter-spacing candidates") echo "nonzero_letter_spacing_candidates" ;;
      "Raw app-facing TextStyle candidates") echo "raw_text_style_candidates" ;;
      "Legacy 4-point spacing migration candidates") echo "legacy_spacing_canonical_candidates" ;;
      "Fine-grained spacing compatibility helpers") echo "fine_grained_spacing_compatibility" ;;
      "Plugin/platform side effects inside presentation code") echo "presentation_plugin_imports" ;;
      "Raw app-facing error surface migration candidates") echo "raw_error_surface_candidates" ;;
      *) echo "" ;;
    esac
  }

  full_output="$(
    WIDGET_CLEANUP_SCAN_FORCE_FULL=1 \
      WIDGET_CLEANUP_SCAN_MAX_LINES=0 \
      bash "$0"
  )"

  echo "Widget cleanup candidate scan summary"
  current_key=""
  while IFS= read -r line; do
    if [[ "$line" == "==> "* ]]; then
      title="${line#==> }"
      current_key="$(summary_key_for "$title")"
      continue
    fi
    if [[ -z "$current_key" ]]; then
      continue
    fi
    if [[ "$line" == "No matches." ]]; then
      echo "  $current_key: 0"
      current_key=""
      continue
    fi
    if [[ "$line" =~ ^([0-9]+)[[:space:]]match\(es\)\. ]]; then
      echo "  $current_key: ${BASH_REMATCH[1]}"
      current_key=""
    fi
  done <<<"$full_output"
  exit 0
fi

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
    local start=$((line > 28 ? line - 28 : 1))
    local end=$((line + 20))
    local context
    context="$(sed -n "${start},${end}p" "$file")"
    local line_text
    line_text="$(sed -n "${line}p" "$file")"

    if grep -Eq 'Container\(color:' <<<"$line_text"; then
      continue
    fi

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
  echo "==> Raw text input candidates that should use CatchField.input or a field-specific primitive"
  local output
  output="$(rg -n \
    "${common_globs[@]}" \
    '(^|[^A-Za-z])(TextField|TextFormField)\(' \
    lib/core lib/*/presentation \
    --glob '!lib/core/widgets/catch_field.dart' \
    --glob '!lib/core/widgets/catch_field_*.dart' \
    --glob '!lib/core/widgets/catch_search_field.dart' \
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
    if [[ "$file" == lib/event_success/presentation/companion_parts/* ||
      "$file" == lib/event_success/presentation/live_reveal_parts/* ]]; then
      continue
    fi
    local start=$((line > 12 ? line - 12 : 1))
    local end=$((line + 18))
    local context
    context="$(sed -n "${start},${end}p" "$file")"
    local line_text
    line_text="$(sed -n "${line}p" "$file")"

    if grep -Eq 'Container\(color:' <<<"$line_text"; then
      continue
    fi
    if grep -Eq 'LinearGradient|RadialGradient|CustomPaint|Image\.|Image\(|BoxFit\.|StackFit\.expand|FractionallySizedBox|photoPlaceholder|t\.heroGrad|profile-inline-underline' <<<"$context"; then
      continue
    fi
    if grep -Eq 'Positioned\(' <<<"$context" &&
      grep -Eq 'shape: BoxShape\.circle' <<<"$context"; then
      continue
    fi

    # Layout-only containers and animation-only shells are often legitimate.
    # Flag local shells that own fill/border/radius/shadow decoration, because
    # those are the cases most likely to drift from CatchSurface/tokens.
    if grep -Eq 'decoration: BoxDecoration\(' <<<"$context" &&
      grep -Eq 'gradient:|borderRadius:|Border\.all|boxShadow:|shape:' <<<"$context" &&
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

scan_low_level_typography_roles() {
  echo
  echo "==> App-facing low-level typography role candidates"
  local output
  output="$(rg -n \
    "${common_globs[@]}" \
    'CatchTextStyles\.(bodyS|bodyM|titleS)\(' \
    lib/core/widgets lib/*/presentation \
    --glob '!lib/core/widgets/catch_bottom_sheet.dart' \
    --glob '!lib/core/widgets/catch_empty_state.dart' \
    --glob '!lib/core/widgets/catch_search_field.dart' || true)"

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

scan_nonzero_letter_spacing() {
  echo
  echo "==> Nonzero letter-spacing candidates"
  local output
  output="$(rg -n \
    "${common_globs[@]}" \
    'letterSpacing:' \
    lib \
    --glob '!lib/core/theme/catch_fonts.dart' \
    --glob '!lib/core/theme/catch_text_styles.dart' || true)"

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

scan_raw_text_styles() {
  echo
  echo "==> Raw app-facing TextStyle candidates"
  local output
  output="$(rg -n \
    "${common_globs[@]}" \
    '(^|[^A-Za-z])TextStyle\(' \
    lib/core/widgets lib/*/presentation \
    --glob '!lib/core/widgets/catch_otp_code_field.dart' \
    --glob '!lib/core/widgets/catch_top_bar.dart' || true)"

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
  test \
  --glob '!test/test_pump_helpers.dart'

scan "Async unit-test flush candidates" \
  'Future<void>\.delayed\(Duration\.zero\)' \
  test

scan "Brittle positional widget finders" \
  'find\.[A-Za-z]+\([^)]*\)\.(at|first|last)|Scrollable\.first|ListView\.first' \
  test \
  --glob '!test/test_pump_helpers.dart'

scan "Presentation widgets reaching directly into repository providers" \
  'ref\.(read|watch)\([^)]*RepositoryProvider' \
  lib/core/presentation lib/*/presentation \
  --glob '!**/*_provider.dart' \
  --glob '!**/*_actions.dart' \
  --glob '!**/*_lookup.dart'

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

scan_low_level_typography_roles

scan_nonzero_letter_spacing

scan_raw_text_styles

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
