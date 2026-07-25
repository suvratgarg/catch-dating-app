#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 3 ]]; then
  echo "Usage: ./tool/use_firebase_environment.sh <dev|staging|prod> [consumer|host] [project-root]"
  exit 1
fi

environment="$1"
app_role="${2:-consumer}"
project_root="${3:-.}"

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
destination_root="$repo_root/$project_root"
if [[ ! -f "$destination_root/pubspec.yaml" ]]; then
  echo "Flutter project root has no pubspec.yaml: $project_root"
  exit 1
fi

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
  dest_rel="${spec##*|}"
  source_path="$repo_root/$source_rel"
  destination_path="$destination_root/$dest_rel"
  destination_parent="$(dirname "$destination_path")"
  if [[ ! -f "$source_path" ]]; then
    echo "Missing Firebase config file: $source_rel"
    missing=1
  elif [[ ! -d "$destination_parent" ]]; then
    continue
  fi
done

if [[ $missing -ne 0 ]]; then
  echo "See firebase/README.md for the expected directory layout."
  exit 1
fi

for spec in "${copy_specs[@]}"; do
  source_rel="${spec%%|*}"
  dest_rel="${spec##*|}"
  destination_path="$destination_root/$dest_rel"
  if [[ ! -d "$(dirname "$destination_path")" ]]; then
    continue
  fi
  cp "$repo_root/$source_rel" "$destination_path"
  echo "Applied $source_rel -> $project_root/$dest_rel"
done

bash "$repo_root/tool/validate_firebase_environment.sh" \
  "$environment" \
  "$app_role" \
  "$project_root" >/dev/null

echo "Active Firebase environment: $environment ($app_role)"
