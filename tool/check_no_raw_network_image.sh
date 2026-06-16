#!/usr/bin/env bash
#
# Regression guard: feature UI must load remote images through the
# CatchNetworkImage primitive, never a raw Image.network widget, so every
# remote image gets consistent decode sizing and a branded error state.
#
# The natural home for this is a catch_ui_lints analyzer rule
# (catch_no_raw_network_image). That rule could not be added yet because the
# analyzer plugin cannot be recompiled in the current local toolchain without
# crashing `dart analyze` (a fresh plugin compile fails; the committed bytes
# only pass via a cached compile). This pure-grep gate enforces the same
# invariant in the meantime and is intentionally cheap and dependency-free.
#
# Scope notes:
#   - Only Image.network (the Widget) is guarded. Raw NetworkImage (an
#     ImageProvider) is allowed because there is no ImageProvider primitive to
#     route it through (e.g. DecorationImage/backgroundImage call sites).
#   - lib/core/widgets/** is exempt: CatchNetworkImage and the other image
#     primitives legitimately own the raw loader.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

matches="$(
  rg --no-heading --line-number 'Image\.network' lib \
    --glob '!lib/core/widgets/**' \
    --glob '!**/*.g.dart' \
    --glob '!**/*.freezed.dart' \
    || true
)"

if [[ -n "$matches" ]]; then
  echo "Raw Image.network found in feature UI. Use CatchNetworkImage instead" >&2
  echo "(lib/core/widgets/catch_network_image.dart):" >&2
  echo "$matches" >&2
  exit 1
fi

echo "check_no_raw_network_image: OK (0 raw Image.network widgets in feature UI)"
