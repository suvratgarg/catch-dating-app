#!/usr/bin/env bash
set -euo pipefail

device="${1:-macos}"

suites=(
  integration_test/app_shell_smoke_test.dart
  integration_test/app_shell_club_flows_test.dart
  integration_test/app_shell_event_flows_test.dart
  integration_test/app_shell_dashboard_flows_test.dart
  integration_test/app_shell_catches_flows_test.dart
  integration_test/app_shell_chat_settings_review_flows_test.dart
  integration_test/app_shell_regression_test.dart
)

for suite in "${suites[@]}"; do
  echo "==> flutter test ${suite} -d ${device}"
  flutter test "${suite}" -d "${device}"
done
