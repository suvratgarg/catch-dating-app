#!/usr/bin/env bash
#
# UI local-constant wrapper scanner.
#
# This catches a common scanner-bypass pattern: moving raw UI values from widget
# arguments into file-local constants, e.g. `const double _cardHeight = 120`.
# Feature/screen files should route those values through Catch tokens or a
# shared primitive instead of owning private design scales.
set -euo pipefail

# shellcheck source=tool/lib/scanner_shell.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/scanner_shell.sh"
scanner_cd_repo_root

usage() {
  cat <<'EOF'
Usage:
  bash tool/check_ui_local_constant_wrappers.sh [--summary|--count|--help]

Modes:
  default    Print summary plus every local raw constant. Exit 1 if targets remain.
  --summary  Print summary and top files only. Exit 1 if targets remain.
  --count    Print only the numeric target count. Always exit 0.

Scope:
  Scans Dart files under lib/**/presentation, excluding generated files, labs,
  and retired explore_concept prototypes.

Policy:
  Private file-local UI constants may name semantic geometry, but their values
  should come from CatchSpacing, CatchRadius, CatchIcon, CatchOpacity,
  CatchElevation, CatchMotion, CatchLayout, or a shared primitive/token. Raw
  numbers/colors/durations in those declarations are migration targets.
EOF
}

scanner_parse_mode "${1:-}"
scanner_require_command "perl"

tmp="$(mktemp "${TMPDIR:-/tmp}/catch-ui-local-constants.XXXXXX")"
trap 'rm -f "$tmp"' EXIT

find lib -type f -name '*.dart' \
  -path '*/presentation/*' \
  ! -name '*.g.dart' ! -name '*.freezed.dart' ! -name '*.mocks.dart' \
  ! -path 'lib/labs/*' ! -path '*explore_concept*' -print0 \
| xargs -0 perl -0777 -ne '
    my $text = $_;
    while ($text =~ /(^[ \t]*(?:static\s+)?const\s+(?:double|int|Color|Duration|Size|Offset|EdgeInsets(?:Geometry)?|BorderRadius|Radius)\s+_[A-Za-z0-9_]*(?:height|width|size|extent|radius|alpha|opacity|elevation|duration|color|shadow|padding|margin|inset|gap|offset)[A-Za-z0-9_]*\s*=\s*[^;]+;)/gmi) {
      my $statement = $1;
      my $match_start = $-[1];
      next if $statement =~ /=\s*(?:CatchSpacing|CatchRadius|CatchIcon|CatchOpacity|CatchElevation|CatchMotion|CatchLayout|CatchStroke|Sizes)\b/s;
      next unless $statement =~ /=\s*(?:-?\d|Color\(|Colors\.|Duration\(|Size\(|Offset\(|EdgeInsets\.|BorderRadius\.|Radius\.)/s;
      my $prefix = substr($text, 0, $match_start);
      my $line_number = ($prefix =~ tr/\n//) + 1;
      $statement =~ s/\s+/ /g;
      $statement =~ s/^\s+|\s+$//g;
      print "$ARGV:$line_number:$statement\n";
    }
  ' \
| sort -t: -k1,1 -k2,2n >"$tmp"

if [ -s "$tmp" ]; then
  total="$(wc -l <"$tmp" | tr -d ' ')"
  files="$(awk -F: '{ files[$1]=1 } END { for (f in files) n++; print n + 0 }' "$tmp")"
else
  total=0
  files=0
fi

if [ "$MODE" = "count" ]; then
  echo "$total"
  exit 0
fi

echo "UI local raw-constant targets: $total"
echo "Files with targets: $files"
echo "Scope: lib/**/presentation Dart files; generated files, labs, and explore_concept excluded."

if [ "$total" -gt 0 ]; then
  echo ""
  echo "Top files:"
  awk -F: '{ counts[$1]++ } END { for (f in counts) print counts[f] "\t" f }' "$tmp" | sort -rn | head -25

  if [ "$MODE" != "summary" ]; then
    echo ""
    echo "Targets:"
    cat "$tmp"
  fi

  echo ""
  echo "Replace raw file-local UI constants with Catch token expressions or shared primitives."
  exit 1
fi

echo "No UI local raw-constant targets found."
