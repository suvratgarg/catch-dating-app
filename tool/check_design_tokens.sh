#!/usr/bin/env bash
#
# Design-token drift scanner (see docs/design_token_migration_prompt.md and
# docs/design_language.md → "Color").
#
# Flags RAW colors, fonts, and text styles that bypass the token system, so the
# whole app re-skins from a single source (CatchTokens / ActivityPalette /
# CatchTextStyles / CatchFonts). A finding is cleared by EITHER:
#   (a) routing it through a token — CatchTokens.of(context).<role>,
#       ActivityPalette.of(context).forKind(kind), CatchTextStyles.<style>(context),
#       or CatchFonts.<serif|sans|mono>(...), OR
#   (b) annotating the SAME line `// token:allow: <reason>` for a sanctioned raw
#       value (CustomPainter pattern/glyph fill, platform-fixed brand/map color, …).
#
# Deterministic: same tree in -> same findings out. A clean exit (0) means every
# remaining raw value is justified.
#
# Portable: uses `perl` + `find` only (no ripgrep / GNU-grep -P), so it runs
# identically on macOS dev machines and Linux CI. (The `Colors.(?!transparent)`
# negative-lookahead and comment-skipping require perl, not BSD grep.)
set -uo pipefail

# shellcheck source=tool/lib/scanner_shell.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/scanner_shell.sh"
scanner_cd_repo_root

usage() {
  cat <<'EOF'
Usage:
  bash tool/check_design_tokens.sh [--summary|--count|--help]

Modes:
  default    Print every raw color/font/text-style candidate. Exit 1 if any remain.
  --summary  Print only the candidate count and doctrine pointer. Exit 1 if any remain.
  --count    Print only the numeric candidate count. Always exit 0.
EOF
}

scanner_parse_mode "${1:-}"
scanner_require_command "perl"

# Exempt: generated code; the token DEFINITIONS themselves — lib/core/theme/**
# (CatchTokens, ActivityPalette, CatchTextStyles, CatchFonts, CatchElevation
# shadows, the static pin/map/celebration palettes) and graded_image.dart
# (CatchGrade tints); and retired sandboxes. Everything else routes through the
# token system or is annotated `// token:allow: <reason>`.
FINDINGS="$(
  find lib -type f -name '*.dart' \
    ! -name '*.g.dart' ! -name '*.freezed.dart' \
    ! -path 'lib/core/theme/*' ! -path 'lib/core/widgets/graded_image.dart' \
    ! -path 'lib/labs/*' ! -path '*explore_concept*' -print0 \
  | xargs -0 perl -ne '
      # Skip if this line OR the line directly above carries the escape hatch.
      # (Annotation-above is robust to dart format wrapping a long color expr.)
      my $allow = /token:allow/ || (defined $prev && $prev =~ /token:allow/);
      unless ($allow || m{^\s*//}) {                # also skip comment-only lines
        if (
          /Color\(0x/                                 # hex literal color
          || /Color\.from(?:RGBO|ARGB)\(/             # raw component color
          || /\bColors\.(?!transparent\b)[A-Za-z]/    # named Material color (transparent allowed)
          || /\bTextStyle\(/                          # raw TextStyle (use CatchTextStyles)
          || /GoogleFonts\.|\.getFont\(/              # font-API drift (use CatchFonts)
        ) {
          my $line = $_;
          $line =~ s/^\s+//;
          print "$ARGV:$.:$line";
        }
      }
      $prev = $_;
      if (eof) { close ARGV; undef $prev; }         # reset $. and prev-line per file
    ' \
  | sort -t: -k1,1 -k2,2n
)"

if [ -n "$FINDINGS" ]; then
  COUNT="$(printf '%s\n' "$FINDINGS" | wc -l | tr -d ' ')"
  if [ "$MODE" = "count" ]; then
    echo "$COUNT"
    exit 0
  fi
  echo "✗ Design tokens: ${COUNT} raw color/font/text-style candidate(s) outside the token system."
  echo "  Route through CatchTokens / ActivityPalette / CatchTextStyles / CatchFonts,"
  echo "  or annotate the line: // token:allow: <reason>"
  echo "  Playbook: docs/design_token_migration_prompt.md"
  if [ "$MODE" = "full" ]; then
    echo ""
    printf '%s\n' "$FINDINGS"
  fi
  exit 1
fi

if [ "$MODE" = "count" ]; then
  echo "0"
  exit 0
fi

echo "✓ Design tokens: no raw colors/fonts/text-styles outside the token system."
