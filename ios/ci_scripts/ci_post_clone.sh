#!/usr/bin/env bash
set -euo pipefail
trap 'status=$?; echo "ci_post_clone.sh failed at line $LINENO: $BASH_COMMAND"; exit $status' ERR

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_with_retry() {
  local attempts="$1"
  local delay_seconds="$2"
  shift 2

  local attempt=1
  while true; do
    if "$@"; then
      return 0
    fi

    if (( attempt >= attempts )); then
      echo "Command failed after $attempt attempts: $*"
      return 1
    fi

    echo "Command failed on attempt $attempt/$attempts: $*"
    echo "Retrying in ${delay_seconds}s..."
    sleep "$delay_seconds"
    attempt=$((attempt + 1))
  done
}

ensure_cocoapods() {
  if command -v pod >/dev/null 2>&1; then
    return 0
  fi

  echo "Installing CocoaPods"
  if command -v brew >/dev/null 2>&1; then
    brew install cocoapods
  elif command -v gem >/dev/null 2>&1 && command -v ruby >/dev/null 2>&1; then
    gem install --user-install cocoapods
    export PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH"
  else
    echo "Neither CocoaPods, Homebrew, nor RubyGems is available on this runner."
    exit 127
  fi
}

ensure_node() {
  if command -v node >/dev/null 2>&1; then
    echo "Using Node $(node --version)"
    return 0
  fi

  local node_version="${NODE_VERSION:?NODE_VERSION is missing from tool/ci/toolchain.env}"
  local node_formula="node@$node_version"

  if ! command -v brew >/dev/null 2>&1; then
    echo "Node is required for release config validation, but node and Homebrew are unavailable."
    return 127
  fi

  echo "Installing Node $node_version for Xcode Cloud"
  brew install "$node_formula"

  local node_prefix
  node_prefix="$(brew --prefix "$node_formula")"
  export PATH="$node_prefix/bin:$PATH"

  if ! command -v node >/dev/null 2>&1; then
    echo "Installed $node_formula, but node is still not on PATH."
    return 127
  fi

  echo "Using Node $(node --version)"
}

load_toolchain_env() {
  local toolchain_file="$1"
  local flutter_version_override="${FLUTTER_VERSION:-}"

  if [[ ! -f "$toolchain_file" ]]; then
    echo "Missing toolchain file: $toolchain_file"
    return 1
  fi

  set -a
  # shellcheck source=/dev/null
  source "$toolchain_file"
  set +a

  if [[ -n "$flutter_version_override" ]]; then
    FLUTTER_VERSION="$flutter_version_override"
  fi
}

if [[ -n "${CI_PRIMARY_REPOSITORY_PATH:-}" ]]; then
  repo_root="$CI_PRIMARY_REPOSITORY_PATH"
elif [[ -f "$script_dir/../pubspec.yaml" ]]; then
  repo_root="$(cd "$script_dir/.." && pwd)"
else
  repo_root="$(cd "$script_dir/../.." && pwd)"
fi
cd "$repo_root"

load_toolchain_env "$repo_root/tool/ci/toolchain.env"
flutter_version="${FLUTTER_VERSION:?FLUTTER_VERSION is missing from tool/ci/toolchain.env}"
flutter_home="${CI_WORKSPACE_PATH:-$HOME}/flutter"

if [[ ! -x "$flutter_home/bin/flutter" ]]; then
  echo "Installing Flutter $flutter_version for Xcode Cloud"
  git clone --depth 1 --branch "$flutter_version" https://github.com/flutter/flutter.git "$flutter_home"
fi

export PATH="$flutter_home/bin:$PATH"

flutter config --no-analytics
flutter --version
flutter precache --ios

app_role="${CATCH_APP_ROLE:-consumer}"
if [[ "${CI_XCODEBUILD_SCHEME:-}" == host-* ]]; then
  app_role="host"
fi
case "$app_role" in
  consumer|host) ;;
  *)
    echo "Unsupported CATCH_APP_ROLE: $app_role"
    echo "Use consumer or host."
    exit 64
    ;;
esac

version_line="$(awk '/^version: / { print $2; exit }' pubspec.yaml)"
build_name="${FLUTTER_BUILD_NAME:-${version_line%%+*}}"

if [[ -n "${FLUTTER_BUILD_NUMBER:-}" ]]; then
  build_number="$FLUTTER_BUILD_NUMBER"
elif [[ -n "${CI_BUILD_NUMBER:-}" ]]; then
  build_number="$(date -u +%Y%m%d)${CI_BUILD_NUMBER}"
else
  build_number="$(date -u +%Y%m%d%H%M)"
fi

echo "Preparing Flutter iOS config for prod/$app_role $build_name ($build_number)"

# ios/Flutter/GoogleMapsKeys.xcconfig is gitignored, so it is absent from a
# fresh CI clone. Without it the GoogleMapsApiKey Info.plist value is empty,
# GMSServices.provideAPIKey is skipped, and every map screen crashes at runtime.
echo "Writing prod iOS Google Maps key"
./tool/write_ios_maps_key_xcconfig.sh prod

ensure_cocoapods
ensure_node
run_with_retry 3 20 flutter pub get
run_with_retry 3 30 ./tool/flutter_with_env.sh prod --role "$app_role" build ios \
  --config-only \
  --release \
  --build-name="$build_name" \
  --build-number="$build_number"

cd ios
run_with_retry 3 30 pod install
