#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: ./tool/use_firebase_environment.sh <dev|staging|prod>"
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

copy_specs=(
  "firebase/$environment/android/google-services.json|android/app/google-services.json"
  "firebase/$environment/ios/GoogleService-Info.plist|ios/Runner/GoogleService-Info.plist"
  "firebase/$environment/macos/GoogleService-Info.plist|macos/Runner/GoogleService-Info.plist"
  "firebase/$environment/web/firebase-messaging-sw.js|web/firebase-messaging-sw.js"
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

"$repo_root/tool/validate_firebase_environment.sh" "$environment" >/dev/null

echo "Active Firebase environment: $environment"
