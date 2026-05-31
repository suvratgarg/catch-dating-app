#!/usr/bin/env bash
#
# UI-system allow-comment debt scanner.
#
# This gate exists to prevent raw-value scanners from being bypassed by adding
# blanket `*:allow:` annotations. A zero raw-target count is not meaningful while
# this scanner still reports allow-comment debt.
#
# Supported markers:
#   ui-system:allow:
#   color-sweep:allow:
#   sizing:allow:
#   spacing:allow:
#   radius:allow:
#   icon-size:allow:
#   typography:allow:
#   motion:allow:
#   surface:allow:
#   alpha:allow:
#   shadow:allow:
#   breakpoint:allow:
#   control:allow:
set -euo pipefail

# shellcheck source=tool/lib/scanner_shell.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/scanner_shell.sh"
scanner_cd_repo_root

usage() {
  cat <<'EOF'
Usage:
  bash tool/check_ui_allow_debt.sh [--summary|--count|--help]

Modes:
  default    Print summary plus every allow marker. Exit 1 if markers remain.
  --summary  Print summary only. Exit 1 if markers remain.
  --count    Print only the numeric marker count. Always exit 0.

Scope:
  Scans lib and test Dart files, excluding generated files. Unlike the raw-value
  scanners, this intentionally includes prototypes and concept files: exception
  comments in excluded code are still migration debt/noise.

Policy:
  Allow comments are temporary debt, not migration. A line should be allowed only
  when the raw value is a genuinely fixed product/artifact contract and the
  reason is specific enough for a reviewer to understand why no token/primitive
  should own it.
EOF
}

scanner_parse_mode "${1:-}"
scanner_require_command "rg" "ripgrep (rg)"

paths=()
[ -d lib ] && paths+=("lib")
[ -d test ] && paths+=("test")

if [ "${#paths[@]}" -eq 0 ]; then
  echo "No lib or test directory found." >&2
  exit 2
fi

tmp="$(mktemp "${TMPDIR:-/tmp}/catch-ui-allow-debt.XXXXXX")"
trap 'rm -f "$tmp"' EXIT

pattern='(ui-system|color-sweep|sizing|spacing|radius|icon-size|typography|motion|surface|alpha|shadow|breakpoint|control):allow:'

rg -n \
  --glob '!**/*.g.dart' \
  --glob '!**/*.freezed.dart' \
  --glob '!**/*.mocks.dart' \
  "$pattern" \
  "${paths[@]}" \
  | perl -ne '
      chomp;
      my $line = $_;
      while ($line =~ /\b(ui-system|color-sweep|sizing|spacing|radius|icon-size|typography|motion|surface|alpha|shadow|breakpoint|control):allow:/g) {
        print "$1:$line\n";
      }
    ' \
  | sort -t: -k1,1 -k2,2 -k3,3n >"$tmp" || true

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

echo "UI allow-comment debt: $total"
echo "Files with allow debt: $files"
echo "Scope: lib and test Dart files; generated files excluded; prototypes included."

if [ "$total" -gt 0 ]; then
  echo ""
  echo "By category:"
  awk -F: '{ counts[$1]++ } END { for (c in counts) print counts[c] "\t" c }' "$tmp" | sort -rn

  echo ""
  echo "Top files:"
  awk -F: '{ counts[$2]++ } END { for (f in counts) print counts[f] "\t" f }' "$tmp" | sort -rn | head -25

  echo ""
  echo "Weak/generic reason hints:"
  perl -ne '
    my @weak = (
      "sanctioned visual",
      "design-system typography",
      "component icon",
      "layout inset",
      "visual layering",
      "card shadow",
      "component surface",
      "design-system control size",
      "layout constant",
      "animation timing",
    );
    for my $reason (@weak) {
      $counts{$reason}++ if index($_, $reason) >= 0;
    }
    END {
      for my $reason (sort { $counts{$b} <=> $counts{$a} || $a cmp $b } keys %counts) {
        print "$counts{$reason}\t$reason\n";
      }
    }
  ' "$tmp" | head -25

  if [ "$MODE" != "summary" ]; then
    echo ""
    echo "Findings:"
    cat "$tmp"
  fi

  echo ""
  echo "Migrate these values or replace only the genuinely fixed exceptions with narrow, reviewer-grade reasons."
  exit 1
fi

echo "No UI allow-comment debt found."
