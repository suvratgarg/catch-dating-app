#!/usr/bin/env bash
set -euo pipefail

mode="${1:-headless}"

native_suites=(
  integration_test/app_shell_smoke_test.dart
  integration_test/app_shell_club_flows_test.dart
  integration_test/app_shell_event_flows_test.dart
  integration_test/app_shell_dashboard_flows_test.dart
  integration_test/app_shell_catches_flows_test.dart
  integration_test/app_shell_chat_settings_review_flows_test.dart
  integration_test/app_shell_regression_test.dart
)

if [[ "${mode}" == "headless" ]]; then
  headless_suites=(
    test/integration/app_shell_smoke_test.dart
    test/integration/app_shell_club_flows_test.dart
    test/integration/app_shell_event_flows_test.dart
    test/integration/app_shell_dashboard_flows_test.dart
    test/integration/app_shell_catches_flows_test.dart
    test/integration/app_shell_chat_settings_review_flows_test.dart
    test/integration/app_shell_regression_test.dart
  )
  echo "==> flutter test --concurrency=1 test/integration"
  flutter test --concurrency=1 "${headless_suites[@]}"
  exit 0
fi

for suite in "${native_suites[@]}"; do
  echo "==> flutter test ${suite} -d ${mode} (native integration binding)"
  flutter test \
    --dart-define=APP_SHELL_NATIVE_INTEGRATION=true \
    "${suite}" \
    -d "${mode}"
done
