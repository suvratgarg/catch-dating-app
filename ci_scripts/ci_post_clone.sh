#!/usr/bin/env bash
set -euo pipefail
trap 'status=$?; echo "ci_post_clone.sh failed at line $LINENO: $BASH_COMMAND"; exit $status' ERR

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -n "${CI_PRIMARY_REPOSITORY_PATH:-}" ]]; then
  repo_root="$CI_PRIMARY_REPOSITORY_PATH"
elif [[ -f "$script_dir/../pubspec.yaml" ]]; then
  repo_root="$(cd "$script_dir/.." && pwd)"
else
  repo_root="$(cd "$script_dir/../.." && pwd)"
fi
cd "$repo_root"

flutter_version="${FLUTTER_VERSION:-3.41.9}"
flutter_home="${CI_WORKSPACE_PATH:-$HOME}/flutter"

if [[ ! -x "$flutter_home/bin/flutter" ]]; then
  echo "Installing Flutter $flutter_version for Xcode Cloud"
  git clone --depth 1 --branch "$flutter_version" https://github.com/flutter/flutter.git "$flutter_home"
fi

export PATH="$flutter_home/bin:$PATH"

flutter config --no-analytics
flutter --version
flutter precache --ios

version_line="$(awk '/^version: / { print $2; exit }' pubspec.yaml)"
build_name="${FLUTTER_BUILD_NAME:-${version_line%%+*}}"

if [[ -n "${FLUTTER_BUILD_NUMBER:-}" ]]; then
  build_number="$FLUTTER_BUILD_NUMBER"
elif [[ -n "${CI_BUILD_NUMBER:-}" ]]; then
  build_number="$(date -u +%Y%m%d)${CI_BUILD_NUMBER}"
else
  build_number="$(date -u +%Y%m%d%H%M)"
fi

echo "Preparing Flutter iOS config for prod $build_name ($build_number)"
./tool/use_firebase_environment.sh prod >/dev/null

flutter pub get
flutter build ios \
  --config-only \
  --release \
  --flavor prod \
  --build-name="$build_name" \
  --build-number="$build_number" \
  --dart-define-from-file="$repo_root/tool/dart_defines/prod.json"

if ! command -v pod >/dev/null 2>&1; then
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
fi

cd ios
pod install
