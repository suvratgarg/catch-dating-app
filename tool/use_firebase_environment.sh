#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: ./tool/use_firebase_environment.sh <dev|staging|prod> [consumer|host]"
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

missing=0
for spec in "${copy_specs[@]}"; do
  source_rel="${spec%%|*}"
  source_path="$repo_root/$source_rel"
  if [[ ! -f "$source_path" ]]; then
    echo "Missing Firebase config file: $source_rel"
    missing=1
  fi
done

if [[ $missing -ne 0 ]]; then
  echo "See firebase/README.md for the expected directory layout."
  exit 1
fi

for spec in "${copy_specs[@]}"; do
  source_rel="${spec%%|*}"
  dest_rel="${spec##*|}"
  cp "$repo_root/$source_rel" "$repo_root/$dest_rel"
  echo "Applied $source_rel -> $dest_rel"
done

bash "$repo_root/tool/validate_firebase_environment.sh" "$environment" "$app_role" >/dev/null

echo "Active Firebase environment: $environment ($app_role)"
