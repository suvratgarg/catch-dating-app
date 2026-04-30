#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: ./tool/validate_firebase_environment.sh <dev|staging|prod>"
  exit 1
fi

environment="$1"

case "$environment" in
  dev|staging|prod) ;;
  *)
    echo "Unsupported environment: $environment"
    exit 1
    ;;
esac

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
define_file="$repo_root/tool/dart_defines/$environment.json"

if [[ ! -f "$define_file" ]]; then
  echo "Missing dart define file: tool/dart_defines/$environment.json"
  exit 1
fi

node - "$define_file" "$environment" <<'NODE'
const fs = require("fs");

const [defineFile, expectedEnvironment] = process.argv.slice(2);
const defines = JSON.parse(fs.readFileSync(defineFile, "utf8"));

if (defines.APP_ENV !== expectedEnvironment) {
  console.error(
    `APP_ENV mismatch in ${defineFile}: expected ${expectedEnvironment}, got ${defines.APP_ENV}`
  );
  process.exit(1);
}

if (!defines.FIREBASE_APP_CHECK_WEB_RECAPTCHA_ENTERPRISE_SITE_KEY) {
  console.error(
    `Missing FIREBASE_APP_CHECK_WEB_RECAPTCHA_ENTERPRISE_SITE_KEY in ${defineFile}`
  );
  process.exit(1);
}
NODE

copy_specs=(
  "firebase/$environment/android/google-services.json|android/app/google-services.json"
  "firebase/$environment/ios/GoogleService-Info.plist|ios/Runner/GoogleService-Info.plist"
  "firebase/$environment/macos/GoogleService-Info.plist|macos/Runner/GoogleService-Info.plist"
  "firebase/$environment/web/firebase-messaging-sw.js|web/firebase-messaging-sw.js"
)

status=0
for spec in "${copy_specs[@]}"; do
  source_rel="${spec%%|*}"
  dest_rel="${spec##*|}"
  source_path="$repo_root/$source_rel"
  dest_path="$repo_root/$dest_rel"

  if [[ ! -f "$source_path" ]]; then
    echo "Missing canonical Firebase config file: $source_rel"
    status=1
    continue
  fi

  if [[ ! -f "$dest_path" ]]; then
    echo "Missing active Firebase config file: $dest_rel"
    status=1
    continue
  fi

  if ! cmp -s "$source_path" "$dest_path"; then
    echo "Active Firebase config mismatch: $dest_rel does not match $source_rel"
    status=1
  fi
done

if [[ $status -ne 0 ]]; then
  echo "Run ./tool/use_firebase_environment.sh $environment to refresh active config files."
  exit "$status"
fi

echo "Firebase environment '$environment' is active and internally consistent."
