#!/usr/bin/env bash
set -euo pipefail

mode="${1:-headless}"
scope="${2:-all}"

if [[ "${mode}" == "--self-test" ]]; then
  runner="${BASH_SOURCE[0]}"
  headless_plan="$(
    APP_SHELL_INTEGRATION_DRY_RUN=true bash "${runner}" headless smoke
  )"
  [[ "${headless_plan}" == *"test/integration/app_shell_smoke_test.dart"* ]]
  [[ "${headless_plan}" != *"app_shell_event_flows_test.dart"* ]]

  native_plan="$(
    APP_SHELL_INTEGRATION_DRY_RUN=true bash "${runner}" macos smoke
  )"
  [[ "${native_plan}" == *"--dart-define=APP_SHELL_NATIVE_INTEGRATION=true"* ]]
  [[ "${native_plan}" == *"integration_test/app_shell_smoke_test.dart"* ]]
  [[ "${native_plan}" == *"-d macos"* ]]
  [[ "${native_plan}" != *"app_shell_event_flows_test.dart"* ]]

  if APP_SHELL_INTEGRATION_DRY_RUN=true \
    bash "${runner}" headless unknown >/dev/null 2>&1; then
    echo "Expected an unknown scope to fail closed." >&2
    exit 1
  fi

  echo "App-shell integration runner selection tests passed."
  exit 0
fi

native_suites=(
  integration_test/app_shell_smoke_test.dart
  integration_test/app_shell_club_flows_test.dart
  integration_test/app_shell_event_flows_test.dart
  integration_test/app_shell_dashboard_flows_test.dart
  integration_test/app_shell_catches_flows_test.dart
  integration_test/app_shell_chat_settings_review_flows_test.dart
  integration_test/app_shell_regression_test.dart
)

if [[ "${scope}" != "all" && "${scope}" != "smoke" ]]; then
  echo "Unknown app-shell integration scope: ${scope} (expected all or smoke)." >&2
  exit 64
fi

run_flutter() {
  if [[ "${APP_SHELL_INTEGRATION_DRY_RUN:-false}" == "true" ]]; then
    printf '==> '
    printf '%q ' "$@"
    printf '\n'
    return
  fi
  "$@"
}

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
  if [[ "${scope}" == "smoke" ]]; then
    headless_suites=(test/integration/app_shell_smoke_test.dart)
  fi
  echo "==> flutter test --concurrency=1 test/integration"
  run_flutter flutter test --concurrency=1 "${headless_suites[@]}"
  exit 0
fi

selected_native_suites=("${native_suites[@]}")
if [[ "${scope}" == "smoke" ]]; then
  selected_native_suites=(integration_test/app_shell_smoke_test.dart)
fi

for suite in "${selected_native_suites[@]}"; do
  echo "==> flutter test ${suite} -d ${mode} (native integration binding)"
  run_flutter flutter test \
    --dart-define=APP_SHELL_NATIVE_INTEGRATION=true \
    "${suite}" \
    -d "${mode}"
done
