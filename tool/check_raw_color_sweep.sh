#!/usr/bin/env bash
#
# Raw color/token sweep scanner for UI Elevation Task 1a-iv.
#
# This is a migration-target finder, not the final anti-drift CI gate. It reports
# production Dart lines that still hard-code visible colors instead of routing
# through CatchTokens, ActivityPalette, or another documented token owner.
#
# A finding is cleared by either:
#   1. replacing the raw color with a token/palette value, or
#   2. adding an explicit same-line exception:
#      // color-sweep:allow: <short reason>
#
# Portable: uses perl + find only.
set -euo pipefail

# shellcheck source=tool/lib/scanner_shell.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/scanner_shell.sh"
scanner_cd_repo_root

usage() {
  cat <<'EOF'
Usage:
  bash tool/check_raw_color_sweep.sh [--summary|--count|--help]

Modes:
  default    Print summary plus every remaining target. Exit 1 if targets remain.
  --summary  Print summary and per-file counts only. Exit 1 if targets remain.
  --count    Print only the numeric target count. Always exit 0.

Scope:
  Scans lib/**/*.dart, excluding generated files, lib/labs/**, explore_concept,
  token/theme definitions, and the sanctioned activity-art/photo-grade owners.
EOF
}

scanner_parse_mode "${1:-}"
scanner_require_command "perl"

TARGETS="$(
  find lib -type f -name '*.dart' \
    ! -name '*.g.dart' \
    ! -name '*.freezed.dart' \
    ! -path 'lib/core/theme/*' \
    ! -path 'lib/labs/*' \
    ! -path '*explore_concept*' \
    -print0 \
  | xargs -0 perl -ne '
      my $path = $ARGV;

      # Sanctioned owners: raw values are definitions/tunables here, not sweep
      # targets. Theme files are already excluded by find.
      next if $path eq "lib/core/widgets/graded_image.dart";
      next if $path eq "lib/events/presentation/event_activity_visuals.dart";

      my $line = $_;
      next if $line =~ /^\s*(?:\/\/|\/\*|\*)/; # ignore pure comments/docs
      next if $line =~ /color-sweep:allow:/;

      my @kinds = ();

      # Color(0x...) literals. Treat 0x00...... as transparent and ignore that
      # occurrence; if the same line also has a visible color, it still reports.
      my $has_hex = 0;
      while ($line =~ /\bColor\(\s*0x([0-9a-fA-F]{6}|[0-9a-fA-F]{8})\s*\)/g) {
        my $hex = $1;
        next if length($hex) == 8 && substr($hex, 0, 2) =~ /^00$/;
        $has_hex = 1;
      }
      push @kinds, "hex" if $has_hex;

      # Other raw constructors with literal channels.
      push @kinds, "rgb" if $line =~ /\bColor\.from(?:RGBO|ARGB|ARGB32)\s*\(/;

      # Material color constants. Transparent is layout/control plumbing, not a
      # visible pigment; white/black with opacity are still visible raw colors.
      if (
        $line =~ /\bColors\.(?!(?:transparent)\b)(?:white(?:\d{2})?|black(?:\d{2})?|grey|gray|blueGrey|red|blue|green|amber|orange|teal|purple|pink|brown|yellow|cyan|indigo|lime|deepOrange|deepPurple|lightBlue|lightGreen)(?:Accent)?(?:\b|\.shade[0-9]{2,3})/
      ) {
        push @kinds, "material";
      }

      # Cupertino system colors should also be tokenized or explicitly allowed.
      push @kinds, "cupertino" if $line =~ /\bCupertinoColors\.(?!transparent\b)/;

      if (@kinds) {
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;
        print "$path:$.:", join("+", @kinds), ":$line\n";
      }

      close ARGV if eof;
    ' \
  | sort -t: -k1,1 -k2,2n
)"

if [ -n "$TARGETS" ]; then
  COUNT="$(printf '%s\n' "$TARGETS" | wc -l | tr -d ' ')"
  FILE_COUNT="$(printf '%s\n' "$TARGETS" | awk -F: '{ files[$1]=1 } END { for (f in files) n++; print n + 0 }')"
else
  COUNT=0
  FILE_COUNT=0
fi

if [ "$MODE" = "count" ]; then
  echo "$COUNT"
  exit 0
fi

echo "Raw color/token sweep targets: $COUNT"
echo "Files with targets: $FILE_COUNT"
echo "Scope: lib/**/*.dart excluding generated files, lib/core/theme/**, lib/labs/**, explore_concept, graded_image.dart, and event_activity_visuals.dart."
echo "Ignored: Colors.transparent, transparent 0x00...... literals, comment-only lines, and same-line // color-sweep:allow: reasons."

if [ "$COUNT" -gt 0 ]; then
  echo ""
  echo "Top files:"
  printf '%s\n' "$TARGETS" \
    | awk -F: '{ counts[$1]++ } END { for (f in counts) print counts[f] "\t" f }' \
    | sort -rn \
    | head -25
fi

if [ "$MODE" = "full" ] && [ "$COUNT" -gt 0 ]; then
  echo ""
  echo "Targets:"
  printf '%s\n' "$TARGETS"
fi

if [ "$COUNT" -gt 0 ]; then
  exit 1
fi

exit 0
