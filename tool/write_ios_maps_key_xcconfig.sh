#!/usr/bin/env bash
set -euo pipefail
trap 'status=$?; echo "write_ios_maps_key_xcconfig.sh failed at line $LINENO: $BASH_COMMAND"; exit $status' ERR

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

target_env="${1:-prod}"
case "$target_env" in
  dev|staging|prod) ;;
  *)
    echo "Unsupported iOS Maps key environment: $target_env"
    echo "Use dev, staging, or prod."
    exit 64
    ;;
esac

upper_env="$(printf '%s' "$target_env" | tr '[:lower:]' '[:upper:]')"
key_var="GOOGLE_MAPS_IOS_API_KEY_${upper_env}"
maps_key="${!key_var:-}"

if [[ -z "$maps_key" ]]; then
  echo "Missing $key_var environment variable."
  echo "Add it as a secret environment variable in the active CI release pipeline."
  exit 1
fi

if [[ ! "$maps_key" =~ ^AIza[0-9A-Za-z_-]{20,}$ ]]; then
  echo "$key_var is set but is not a valid Google API key."
  exit 1
fi

output_arg="${2:-ios/Flutter/GoogleMapsKeys.xcconfig}"
if [[ "$output_arg" = /* ]]; then
  output_path="$output_arg"
else
  output_path="$repo_root/$output_arg"
fi
mkdir -p "$(dirname "$output_path")"
printf '%s=%s\n' "$key_var" "$maps_key" > "$output_path"
echo "Wrote $key_var to ${output_path#"$repo_root/"}."
