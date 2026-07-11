#!/usr/bin/env bash
set -euo pipefail
trap 'status=$?; echo "ci_post_xcodebuild.sh failed at line $LINENO: $BASH_COMMAND"; exit $status' ERR

# Fail the Xcode Cloud build if the archive does not match the selected app
# target, version, build, or role capability contract. Keep the Maps check here
# too: a missing key makes the first GMSMapView throw an uncaught exception.

if [[ "${CI_XCODEBUILD_ACTION:-}" != "archive" || -z "${CI_ARCHIVE_PATH:-}" ]]; then
  echo "Not an archive action; skipping iOS release identity verification."
  exit 0
fi

applications_dir="$CI_ARCHIVE_PATH/Products/Applications"
shopt -s nullglob
app_bundles=("$applications_dir"/*.app)
shopt -u nullglob

if (( ${#app_bundles[@]} != 1 )); then
  echo "Expected exactly one archived app in: $applications_dir"
  printf 'Found archived apps: %s\n' "${app_bundles[@]:-none}"
  exit 1
fi

info_plist="${app_bundles[0]}/Info.plist"
if [[ ! -f "$info_plist" ]]; then
  echo "Could not find archived Info.plist at: $info_plist"
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -n "${CI_PRIMARY_REPOSITORY_PATH:-}" ]]; then
  repo_root="$CI_PRIMARY_REPOSITORY_PATH"
else
  repo_root="$(cd "$script_dir/../.." && pwd)"
fi
cd "$repo_root"

xcode_scheme="${CI_XCODE_SCHEME:-${CI_XCODEBUILD_SCHEME:-}}"
app_role="${CATCH_APP_ROLE:-}"
if [[ -z "$app_role" ]]; then
  if [[ "$xcode_scheme" == host-* ]]; then
    app_role="host"
  else
    app_role="consumer"
  fi
fi

identity_args=(
  --archive "$CI_ARCHIVE_PATH"
  --role "$app_role"
  --environment prod
  --expected-xcconfig "$repo_root/ios/Flutter/Generated.xcconfig"
  --receipt "$repo_root/build/ios/release-evidence/${app_role}-xcode-cloud-archive.json"
)
if [[ -n "$xcode_scheme" ]]; then
  identity_args+=(--scheme "$xcode_scheme")
fi

node tool/platform/verify_ios_release_identity.mjs "${identity_args[@]}"

maps_key="$(/usr/libexec/PlistBuddy -c 'Print :GoogleMapsApiKey' "$info_plist" 2>/dev/null || true)"

if [[ -z "$maps_key" ]]; then
  echo "Archived app is missing GoogleMapsApiKey; map screens would crash."
  echo "Set GOOGLE_MAPS_IOS_API_KEY_PROD as a secret environment variable on the Xcode Cloud workflow."
  exit 1
fi
if [[ ! "$maps_key" =~ ^AIza[0-9A-Za-z_-]{20,}$ ]]; then
  echo "Archived GoogleMapsApiKey is a placeholder or was not substituted at build time."
  exit 1
fi

echo "Archived iOS release identity, role entitlements, and Google Maps key verified."
