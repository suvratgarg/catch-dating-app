#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: ./tool/validate_firebase_environment.sh <dev|staging|prod> [consumer|host]"
  exit 1
fi

environment="$1"
app_role="${2:-consumer}"

case "$environment" in
  dev|staging|prod) ;;
  *)
    echo "Unsupported environment: $environment"
    exit 1
    ;;
esac

case "$app_role" in
  consumer|host) ;;
  *)
    echo "Unsupported app role: $app_role"
    exit 1
    ;;
esac

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
define_file="$repo_root/tool/env/dart_defines/$environment.json"

if [[ ! -f "$define_file" ]]; then
  echo "Missing dart define file: tool/env/dart_defines/$environment.json"
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "Firebase target validation requires Node.js."
  exit 127
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

IFS=$'\t' read -r android_config ios_config macos_config web_config <<<"$(
  node "$repo_root/tool/platform/resolve_app_target.mjs" \
    --role "$app_role" \
    --environment "$environment" \
    --fields 'firebase.android.configPath,firebase.ios.configPath,firebase.macos.configPath,firebase.web.configPath'
)"

copy_specs=(
  "$android_config|android/app/google-services.json"
  "$ios_config|ios/Runner/GoogleService-Info.plist"
  "$macos_config|macos/Runner/GoogleService-Info.plist"
  "$web_config|web/firebase-messaging-sw.js"
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
  echo "Run ./tool/use_firebase_environment.sh $environment $app_role to refresh active config files."
  exit "$status"
fi

echo "Firebase environment '$environment' ($app_role) is active and internally consistent."
