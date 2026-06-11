#!/usr/bin/env bash
set -euo pipefail

probe_path="test/riverpod_lint_probe.dart"

cleanup() {
  rm -f "$probe_path"
}
trap cleanup EXIT

cat > "$probe_path" <<'DART'
import 'package:flutter/widgets.dart';

void riverpodLintProbe() {
  runApp(const SizedBox.shrink());
}
DART

set +e
probe_output="$(dart analyze "$probe_path" 2>&1)"
probe_status=$?
set -e

if [[ $probe_status -eq 0 ]]; then
  echo "Riverpod lint probe unexpectedly passed." >&2
  exit 1
fi

if [[ "$probe_output" != *"missing_provider_scope"* ]]; then
  echo "Riverpod lint probe did not emit missing_provider_scope." >&2
  echo "$probe_output" >&2
  exit 1
fi

cleanup
echo "Riverpod lint plugin smoke check passed."
