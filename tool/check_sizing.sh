#!/usr/bin/env bash
#
# Sizing-doctrine scanner (see docs/ui_architecture.md → "Sizing & Constraints").
#
# Flags HARDCODED CONTENT DIMENSIONS that should be expressed as constraints so the
# UI scales seamlessly. A finding is cleared by EITHER:
#   (a) converting it to a constraint-based pattern (AspectRatio / ConstrainedBox
#       min|max / Flexible|Expanded / intrinsics / CatchLayout.maxContentWidth), OR
#   (b) annotating the SAME line with `// sizing:allow: <reason>` for a genuinely
#       fixed case (icon art, logo canvas, QR, platform-fixed graphic, 1px hairline
#       expressed in a non-literal way).
#
# Deterministic: same tree in -> same findings out. Run after migration; a clean
# exit (0) means every remaining fixed dimension is justified.
#
# Portable: uses `perl` + `find` only (no ripgrep / GNU-grep -P dependency), so it
# runs identically on macOS dev machines and Linux CI.
set -uo pipefail

# shellcheck source=tool/lib/scanner_shell.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/scanner_shell.sh"
scanner_cd_repo_root

usage() {
  cat <<'EOF'
Usage:
  bash tool/check_sizing.sh [--summary|--count|--help]

Modes:
  default    Print every remaining hardcoded-dimension candidate. Exit 1 if candidates remain.
  --summary  Print only the candidate count and doctrine pointer. Exit 1 if candidates remain.
  --count    Print only the numeric candidate count. Always exit 0.
EOF
}

scanner_parse_mode "${1:-}"
scanner_require_command "perl"

# Search lib/ only. Exempt: generated code, the design-system scale itself
# (CatchSpacing/CatchRadius/CatchIcon DEFINE the constants), and retired sandboxes.
FINDINGS="$(
  find lib -type f -name '*.dart' \
    ! -name '*.g.dart' ! -name '*.freezed.dart' \
    ! -path 'lib/core/theme/*' ! -path 'lib/labs/*' ! -path '*explore_concept*' -print0 \
  | xargs -0 perl -ne '
      next if /sizing:allow/;                 # explicit, justified escape hatch
      # A numeric literal >= 4 (exempts 0=none, 1=hairline, 2-3=border/stroke/fractional-line-height).
      my $num = qr/(?:[4-9]|[1-9]\d+)(?:\.\d+)?/;
      if (
        # 1) Fixed height/width/dimension named args. Lowercase only, so camelCase
        #    maxHeight/minWidth/strokeWidth are NOT matched -> min/max CONSTRAINTS
        #    (the desired pattern) are intentionally allowed.
        /\b(?:height|width|dimension)\s*:\s*${num}/
        # 2) Tight/expanded constraints (min/max are fine; these pin a fixed size).
        || /BoxConstraints\.(?:tight|tightFor|expand)\b/
        # 3) Fixed Size() literals, e.g. Size(120, 48).
        || /\bSize\(\s*${num}/
        # 4) Dimension-like const/final decls (catches INDIRECTED fixed dims such as
        #    `const double eventTicketMediaHeight = 136;`).
        || /\b(?:const|final)\s+double\s+\w*(?:[Hh]eight|[Ww]idth|[Ss]ize|[Ee]xtent)\w*\s*=\s*${num}/
      ) {
        my $line = $_;
        $line =~ s/^\s+//;
        print "$ARGV:$.:$line";
      }
      close ARGV if eof;                       # reset $. per file
    ' \
  | sort -t: -k1,1 -k2,2n
)"

if [ -n "$FINDINGS" ]; then
  COUNT="$(printf '%s\n' "$FINDINGS" | wc -l | tr -d ' ')"
  if [ "$MODE" = "count" ]; then
    echo "$COUNT"
    exit 0
  fi
  echo "✗ Sizing doctrine: ${COUNT} hardcoded-dimension candidate(s)."
  echo "  Convert to a constraint, or annotate the line: // sizing:allow: <reason>"
  echo "  Doctrine + conversion playbook: docs/ui_architecture.md → Sizing & Constraints."
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

echo "✓ Sizing doctrine: no un-annotated hardcoded content dimensions."
