#!/usr/bin/env bash
set -euo pipefail
trap 'status=$?; echo "ci_post_xcodebuild.sh failed at line $LINENO: $BASH_COMMAND"; exit $status' ERR

# Fail the Xcode Cloud build if the archived app would crash on map screens.
# A missing or unsubstituted GoogleMapsApiKey means GMSServices.provideAPIKey is
# never called, so the first GMSMapView throws an uncaught NSException.

if [[ "${CI_XCODEBUILD_ACTION:-}" != "archive" || -z "${CI_ARCHIVE_PATH:-}" ]]; then
  echo "Not an archive action; skipping Maps key verification."
  exit 0
fi

info_plist="$CI_ARCHIVE_PATH/Products/Applications/Runner.app/Info.plist"
if [[ ! -f "$info_plist" ]]; then
  echo "Could not find archived Info.plist at: $info_plist"
  exit 1
fi

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

echo "Archived iOS Google Maps key verified."
