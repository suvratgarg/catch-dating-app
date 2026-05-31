#!/usr/bin/env bash
#
# UI-system raw-value scanner.
#
# This is a deterministic migration-target finder for values that should not
# keep being invented inside feature screens. It complements:
#   - tool/check_raw_color_sweep.sh  (visible raw colors)
#   - tool/check_sizing.sh           (fixed content dimensions)
#
# Findings should usually be migrated to CatchSpacing, CatchRadius, CatchIcon,
# CatchIcons, CatchTextStyles/CatchFonts, CatchMotion, CatchSurface, CatchButton,
# CatchTextField, CatchRangeSlider, or a new named primitive/token.
#
# Same-line escape hatch for genuine one-offs:
#   // ui-system:allow: <short reason>
# Category-specific allow comments also work, e.g.:
#   // spacing:allow: QR quiet-zone inset
#   // motion:allow: product cooldown timer
set -euo pipefail

# shellcheck source=tool/lib/scanner_shell.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/scanner_shell.sh"
scanner_cd_repo_root

usage() {
  cat <<'EOF'
Usage:
  bash tool/check_ui_system_raw_values.sh [--summary|--count|--help]

Modes:
  default    Print summary plus every remaining target. Exit 1 if targets remain.
  --summary  Print summary and per-category counts only. Exit 1 if targets remain.
  --count    Print only the numeric target count. Always exit 0.

Scope:
  Scans app-facing UI files under lib/core/widgets, lib/core/presentation, and
  every lib/<feature>/presentation directory. Generated files, labs, and retired
  explore_concept prototypes are excluded.
EOF
}

scanner_parse_mode "${1:-}"
scanner_require_command "rg" "ripgrep (rg)"

tmp="$(mktemp "${TMPDIR:-/tmp}/catch-ui-system-raw.XXXXXX")"
trap 'rm -f "$tmp"' EXIT

all_ui_paths=()
feature_paths=()
for path in lib/core/widgets lib/core/presentation; do
  [ -d "$path" ] && all_ui_paths+=("$path")
done
[ -d lib/core/presentation ] && feature_paths+=("lib/core/presentation")
while IFS= read -r path; do
  all_ui_paths+=("$path")
  feature_paths+=("$path")
done < <(find lib -type d -path '*/presentation' | sort)

common_globs=(
  --glob '!**/*.g.dart'
  --glob '!**/*.freezed.dart'
  --glob '!lib/labs/**'
  --glob '!*explore_concept*'
)

filter_lines() {
  local category="$1"
  perl -ne '
    my $category = $ENV{"SCAN_CATEGORY"};
    next if /^[^:]+:\d+:\s*(?:\/\/|\/\*|\*)/;
    next if /ui-system:allow:/;
    next if /'"$category"':allow:/;
    if ($category eq "shadow" && /^([^:]+):(\d+):/ && /boxShadow:/) {
      my ($file, $line) = ($1, $2);
      if (open my $fh, "<", $file) {
        my @lines = <$fh>;
        close $fh;
        my $context = join "", @lines[($line - 1) .. (($line + 3) < @lines ? ($line + 3) : $#lines)];
        next if $context =~ /CatchElevation\./;
      }
    }
    print;
  '
}

record_rg() {
  local category="$1"
  local pattern="$2"
  local output
  output="$(
    SCAN_CATEGORY="$category" rg -n "${common_globs[@]}" "$pattern" "${all_ui_paths[@]}" \
      | filter_lines "$category" \
      | sort -t: -k1,1 -k2,2n -u || true
  )"
  if [ -n "$output" ]; then
    printf '%s\n' "$output" | sed "s/^/${category}:/" >>"$tmp"
  fi
}

record_rg_feature() {
  local category="$1"
  local pattern="$2"
  local output
  output="$(
    SCAN_CATEGORY="$category" rg -n "${common_globs[@]}" "$pattern" "${feature_paths[@]}" \
      | filter_lines "$category" \
      | sort -t: -k1,1 -k2,2n -u || true
  )"
  if [ -n "$output" ]; then
    printf '%s\n' "$output" | sed "s/^/${category}:/" >>"$tmp"
  fi
}

record_surfaces() {
  local raw output
  raw="$(rg -n "${common_globs[@]}" 'Container\(|DecoratedBox\(|AnimatedContainer\(' "${feature_paths[@]}" || true)"
  output=""
  while IFS=: read -r file line _; do
    [ -z "${file:-}" ] && continue
    [ -z "${line:-}" ] && continue
    local start=$((line > 14 ? line - 14 : 1))
    local end=$((line + 22))
    local context
    context="$(sed -n "${start},${end}p" "$file")"
    local line_text
    line_text="$(sed -n "${line}p" "$file")"

    if grep -Eq 'ui-system:allow:|surface:allow:' <<<"$context"; then
      continue
    fi
    if grep -Eq 'Container\(color:' <<<"$line_text"; then
      continue
    fi
    if grep -Eq 'CatchSurface\(|LinearGradient|RadialGradient|CustomPaint|Image\.|Image\(|BoxFit\.|StackFit\.expand|FractionallySizedBox|photoPlaceholder|profile-inline-underline' <<<"$context"; then
      continue
    fi
    if grep -Eq 'decoration: BoxDecoration\(' <<<"$context" &&
      grep -Eq 'gradient:|borderRadius:|Border\.all|boxShadow:|shape:' <<<"$context"; then
      output+="${file}:${line}:${line_text}"$'\n'
    fi
  done <<<"$raw"

  output="$(printf '%s\n' "$output" | sort -t: -k1,1 -k2,2n -u | sed '/^$/d' || true)"
  if [ -n "$output" ]; then
    printf '%s\n' "$output" | sed 's/^/surface:/' >>"$tmp"
  fi
}

record_component_radius_params() {
  local raw output
  raw="$(rg -n "${common_globs[@]}" '\bradius:\s*[0-9]' "${all_ui_paths[@]}" || true)"
  output=""
  while IFS=: read -r file line line_text; do
    [ -z "${file:-}" ] && continue
    [ -z "${line:-}" ] && continue
    local start=$((line > 8 ? line - 8 : 1))
    local end=$((line + 2))
    local context
    context="$(sed -n "${start},${end}p" "$file")"

    if grep -Eq 'ui-system:allow:|radius:allow:' <<<"$context"; then
      continue
    fi
    if grep -Eq 'CatchSurface\(|CatchIconTile\(|CatchBadge\(|CatchControlShell\(' <<<"$context"; then
      output+="${file}:${line}:${line_text}"$'\n'
    fi
  done <<<"$raw"

  output="$(printf '%s\n' "$output" | sort -t: -k1,1 -k2,2n -u | sed '/^$/d' || true)"
  if [ -n "$output" ]; then
    printf '%s\n' "$output" | sed 's/^/radius:/' >>"$tmp"
  fi
}

# Raw spacing and insets. Use CatchSpacing/gap constants or a named layout
# contract instead of anonymous numbers.
record_rg "spacing" '\b(?:padding|margin|minimum|contentPadding|childrenPadding|boundaryMargin):\s*(?:const\s+)?EdgeInsets\.(?:all|fromLTRB)\(\s*[0-9]|\b(?:padding|margin|minimum|contentPadding|childrenPadding|boundaryMargin):\s*(?:const\s+)?EdgeInsets\.(?:only|symmetric)\([^)]*(?:left|top|right|bottom|horizontal|vertical):\s*[0-9]|\bEdgeInsets\.(?:all|fromLTRB)\(\s*[0-9]|\bEdgeInsets\.(?:only|symmetric)\([^)]*(?:left|top|right|bottom|horizontal|vertical):\s*[0-9]|\bSizedBox\(\s*(?:height|width):\s*[1-9]|\b(?:crossAxisSpacing|mainAxisSpacing|runSpacing|spacing):\s*[0-9]'

# Raw radii. Use CatchRadius or a named shape contract.
record_rg "radius" '\b(?:BorderRadius|Radius|RRadius)\.(?:circular|elliptical)\(\s*[0-9]|\bBorderRadius\.(?:vertical|horizontal|only)\([^)]*Radius\.circular\(\s*[0-9]'
record_component_radius_params

# Raw icon sizes. Use CatchIcon sizes or add a semantic size to the owning
# primitive. Large art/icon marks should be explicitly allowed or named.
record_rg "icon-size" '\bIcon(?:ThemeData)?\([^;\n]*\bsize:\s*[0-9]|\biconSize:\s*[0-9]'

# Raw icon source. Route through CatchIcons for semantic icon ownership.
record_rg "icons" '\bIcons\.'

# Raw alpha/opacity levels. Use semantic token helpers or named local constants
# for repeated states like disabled, pressed, overlay, scrim, and muted content.
record_rg "alpha" '\bwithValues\(\s*alpha:\s*(?:0?\.[0-9]+|[01](?:\.0+)?)\s*[,)]|\bOpacity\(\s*opacity:\s*(?:0?\.[0-9]+|[01](?:\.0+)?)\s*[,)]'

# Raw shadows/elevation. Prefer CatchElevation/CatchSurface elevation roles or a
# named component shadow contract. `boxShadow:` itself is allowed when it points
# at CatchElevation; raw `BoxShadow(` entries remain migration targets.
record_rg "shadow" '\bBoxShadow\(|\belevation:\s*[1-9]|\bshadowColor:\s*(?:Colors\.|Color\()'

# Raw width breakpoints. Prefer CatchLayout constants or a named responsive
# contract so large-phone/foldable behavior is not scattered per screen.
record_rg "breakpoint" '\b(?:constraints\.maxWidth|constraints\.minWidth|MediaQuery\.of\(context\)\.size\.width|size\.width|width)\s*[<>]=?\s*[0-9]{3,}'

# Raw grid/tile aspect ratios should be named layout contracts.
record_rg "sizing" '\bchildAspectRatio:\s*[0-9]|\baspectRatio:\s*[0-9]|\bSize(?:\.square)?\(\s*[1-9]'

# Do not combine design tokens inline to smuggle one-off fixed geometry through
# the scanner. If a fixed value is legitimate, add a semantic token; if it can
# flex, derive it from constraints/aspect ratio instead.
record_rg_feature "token-arithmetic" '\bCatch(?:Spacing|Icon|Layout|Stroke)\.[A-Za-z0-9_]+\s*[-+*/]\s*Catch(?:Spacing|Icon|Layout|Stroke)\.[A-Za-z0-9_]+|\bCatch(?:Spacing|Icon|Layout|Stroke)\.[A-Za-z0-9_]+\s*\*\s*[0-9]+|\b[0-9]+\s*\*\s*Catch(?:Spacing|Icon|Layout|Stroke)\.[A-Za-z0-9_]+'

# Raw typography. Use CatchTextStyles/CatchFonts; add named roles instead of
# local font sizes, letter spacing, or low-level text themes.
record_rg "typography" '\bTextStyle\(|\bGoogleFonts\.|\bgetFont\(|Theme\.of\(context\)\.textTheme|\.copyWith\([^)]*(?:fontSize|letterSpacing|height):|\bfontSize:\s*[0-9]|\bletterSpacing:\s*-?[0-9]+(?:\.[0-9]+)?'

# Raw animation timings/curves. Use CatchMotion or a named motion helper.
record_rg "motion" '\b(?:duration|reverseDuration|transitionDuration):\s*(?:const\s+)?Duration\(|\b(?:curve|reverseCurve|switchInCurve|switchOutCurve):\s*Curves\.|\bCurveTween\(curve:\s*Curves\.|\bCurves\.'

# Raw controls. Use Catch primitives, or create the missing primitive first.
record_rg_feature "control" '\b(?:ElevatedButton|OutlinedButton|FilledButton|TextButton|CupertinoButton|FloatingActionButton|TextField|TextFormField|Slider|RangeSlider|SegmentedButton|Switch|Checkbox|Radio|DropdownButton|PopupMenuButton)\('

# Local card/surface shells.
record_surfaces

sort -t: -k1,1 -k2,2 -k3,3n -o "$tmp" "$tmp"

if [ -s "$tmp" ]; then
  total="$(wc -l <"$tmp" | tr -d ' ')"
  files="$(awk -F: '{ files[$2]=1 } END { for (f in files) n++; print n + 0 }' "$tmp")"
else
  total=0
  files=0
fi

if [ "$MODE" = "count" ]; then
  echo "$total"
  exit 0
fi

echo "UI-system raw-value targets: $total"
echo "Files with targets: $files"
echo "Scope: lib/core/widgets, lib/core/presentation, lib/*/presentation; generated files, labs, and explore_concept excluded."
echo "Note: raw visible colors are counted separately by tool/check_raw_color_sweep.sh; fixed content dimensions by tool/check_sizing.sh."

if [ "$total" -gt 0 ]; then
  echo ""
  echo "By category:"
  awk -F: '{ counts[$1]++ } END { for (c in counts) print counts[c] "\t" c }' "$tmp" | sort -rn

  echo ""
  echo "Top files:"
  awk -F: '{ counts[$2]++ } END { for (f in counts) print counts[f] "\t" f }' "$tmp" | sort -rn | head -25
fi

if [ "$MODE" = "full" ] && [ "$total" -gt 0 ]; then
  echo ""
  echo "Targets:"
  cat "$tmp"
fi

if [ "$total" -gt 0 ]; then
  exit 1
fi

exit 0
