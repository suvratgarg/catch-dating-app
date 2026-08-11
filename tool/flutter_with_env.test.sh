#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stub_dir="$(mktemp -d)"
state_dir="$(mktemp -d)"
trap 'rm -rf "$stub_dir" "$state_dir"' EXIT

printf '%s\n' \
  '#!/usr/bin/env bash' \
  'if [[ "$*" == *"resolve_app_target.mjs"* ]]; then' \
  '  printf "apps/host\tlib/main_prod.dart\thost-prod\thostProd\n"' \
  'fi' \
  >"$stub_dir/node"
chmod +x "$stub_dir/node"

printf '%s\n' \
  '#!/bin/bash' \
  'if [[ "${1:-}" == *"/tool/use_firebase_environment.sh" ]]; then' \
  '  exit 0' \
  'fi' \
  'exec /bin/bash "$@"' \
  >"$stub_dir/bash"
chmod +x "$stub_dir/bash"

printf '%s\n' \
  '#!/usr/bin/env bash' \
  'counter_file="${FLUTTER_STUB_COUNT_FILE:?}"' \
  'count=0' \
  'if [[ -f "$counter_file" ]]; then count="$(<"$counter_file")"; fi' \
  'count=$((count + 1))' \
  'printf "%s\n" "$count" >"$counter_file"' \
  'case "${FLUTTER_STUB_MODE:-success}" in' \
  '  tls-once)' \
  '    if [[ "$count" == "1" ]]; then' \
  '      echo "Error running pod install" >&2' \
  '      echo "fatal: unable to access '\''https://github.com/SDWebImage/SDWebImage.git/'\'': SSL certificate problem: self signed certificate" >&2' \
  '      exit 1' \
  '    fi' \
  '    ;;' \
  '  tls-always)' \
  '    echo "Error output from CocoaPods:" >&2' \
  '    echo "fatal: unable to access '\''https://github.com/razorpay/razorpay-customui-pod.git/'\'': SSL certificate problem: self signed certificate" >&2' \
  '    exit 1' \
  '    ;;' \
  '  compile-error)' \
  '    echo "Dart compilation failed" >&2' \
  '    exit 17' \
  '    ;;' \
  'esac' \
  'exit 0' \
  >"$stub_dir/flutter"
chmod +x "$stub_dir/flutter"

expect_rejected() {
  local expected="$1"
  shift
  local output
  if output="$(PATH="$stub_dir:$PATH" bash "$repo_root/tool/flutter_with_env.sh" "$@" 2>&1)"; then
    echo "Expected command to reject mismatched app-target arguments: $*" >&2
    exit 1
  fi
  if [[ "$output" != *"$expected"* ]]; then
    echo "Expected rejection containing '$expected', got:" >&2
    echo "$output" >&2
    exit 1
  fi
}

expect_rejected \
  "resolves flavor 'host-prod'; caller supplied 'prod'" \
  prod --role host build ios --flavor prod
expect_rejected \
  "resolves entrypoint 'lib/main_prod.dart'; caller supplied 'lib/main_consumer_prod.dart'" \
  prod --role host build ios -t lib/main_consumer_prod.dart

run_stubbed_ios_build() {
  local mode="$1"
  local ci="$2"
  local counter_file="$3"
  local output_var="$4"
  local status_var="$5"
  local output
  local status
  set +e
  output="$(
    PATH="$stub_dir:$PATH" \
      CI="$ci" \
      GITHUB_ACTIONS=false \
      FLUTTER_STUB_MODE="$mode" \
      FLUTTER_STUB_COUNT_FILE="$counter_file" \
      CATCH_COCOAPODS_TLS_RETRY_DELAY_SECONDS=0 \
      /bin/bash "$repo_root/tool/flutter_with_env.sh" \
      dev --role host build ios --debug --simulator --no-codesign 2>&1
  )"
  status=$?
  set -e
  printf -v "$output_var" '%s' "$output"
  printf -v "$status_var" '%s' "$status"
}

retry_counter="$state_dir/retry-count"
run_stubbed_ios_build tls-once true "$retry_counter" retry_output retry_status
if [[ "$retry_status" != "0" || "$(<"$retry_counter")" != "2" ]]; then
  echo "Expected exact CocoaPods Git TLS failure to succeed on bounded retry." >&2
  echo "$retry_output" >&2
  exit 1
fi
if [[ "$retry_output" != *"Retrying the iOS Flutter build after a transient verified GitHub certificate failure (attempt 2/3)."* ]]; then
  echo "Expected a visible bounded-retry diagnostic." >&2
  echo "$retry_output" >&2
  exit 1
fi

compile_counter="$state_dir/compile-count"
run_stubbed_ios_build compile-error true "$compile_counter" compile_output compile_status
if [[ "$compile_status" != "17" || "$(<"$compile_counter")" != "1" ]]; then
  echo "Expected non-TLS compile failures to fail immediately without retry." >&2
  echo "$compile_output" >&2
  exit 1
fi

exhausted_counter="$state_dir/exhausted-count"
run_stubbed_ios_build tls-always true "$exhausted_counter" exhausted_output exhausted_status
if [[ "$exhausted_status" != "1" || "$(<"$exhausted_counter")" != "3" ]]; then
  echo "Expected CocoaPods Git TLS retries to stop after exactly three attempts." >&2
  echo "$exhausted_output" >&2
  exit 1
fi

local_counter="$state_dir/local-count"
run_stubbed_ios_build tls-once false "$local_counter" local_output local_status
if [[ "$local_status" != "1" || "$(<"$local_counter")" != "1" ]]; then
  echo "Expected local Flutter builds to retain single-attempt behavior." >&2
  echo "$local_output" >&2
  exit 1
fi

echo "flutter_with_env app-target and bounded CocoaPods TLS retry checks passed."
