#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
Usage: ./tool/run_host_dev_simulator.sh [device-name] [flutter run args...]

Runs the Catch host dev app on an iOS simulator with the local App Check debug
token loaded through tool/flutter_with_env.sh.

Examples:
  ./tool/run_host_dev_simulator.sh
  ./tool/run_host_dev_simulator.sh "iPhone 17 Pro" --no-resident
EOF
  exit 0
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
device="${CATCH_IOS_SIMULATOR_DEVICE:-iPhone 17 Pro}"

if [[ $# -gt 0 && "${1:-}" != --* ]]; then
  device="$1"
  shift
fi

export USE_FIREBASE_APP_CHECK_DEBUG_PROVIDER="${USE_FIREBASE_APP_CHECK_DEBUG_PROVIDER:-true}"
export VERBOSE_AUTH_DEBUG_LOGS="${VERBOSE_AUTH_DEBUG_LOGS:-true}"

exec "$script_dir/flutter_with_env.sh" dev --role host run -d "$device" --debug "$@"
