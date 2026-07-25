#!/bin/bash
set -euo pipefail

if [[ "${PLATFORM_NAME:-}" != "iphoneos" ]]; then
  echo "Skipping Flutter native asset signing for ${PLATFORM_NAME:-unknown platform}"
  exit 0
fi

if [[ "${CODE_SIGNING_ALLOWED:-}" != "YES" ]]; then
  echo "Skipping Flutter native asset signing because code signing is not allowed"
  exit 0
fi

if [[ -z "${EXPANDED_CODE_SIGN_IDENTITY:-}" || "${EXPANDED_CODE_SIGN_IDENTITY}" == "-" ]]; then
  echo "Skipping Flutter native asset signing because no expanded signing identity is available"
  exit 0
fi

framework_path="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/objective_c.framework"

if [[ ! -d "$framework_path" ]]; then
  echo "No Flutter objective_c native asset framework found at $framework_path"
  exit 0
fi

echo "Signing Flutter native asset framework: $framework_path"
/usr/bin/codesign \
  --force \
  --sign "$EXPANDED_CODE_SIGN_IDENTITY" \
  --timestamp=none \
  "$framework_path"
