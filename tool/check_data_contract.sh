#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

before_diff="$(mktemp)"
after_diff="$(mktemp)"
cleanup() {
  rm -f "$before_diff" "$after_diff"
}
trap cleanup EXIT

echo "==> Checking generated Firestore TypeScript types"
git diff -- functions/src/shared/firestore.ts >"$before_diff"
dart tool/generate_firestore_types.dart
git diff -- functions/src/shared/firestore.ts >"$after_diff"
if ! diff -u "$before_diff" "$after_diff"; then
  echo
  echo "Generated Firestore types are stale."
  echo "Run: dart tool/generate_firestore_types.dart"
  exit 1
fi

echo "==> Analyzing Firestore type generator"
dart analyze tool/generate_firestore_types.dart

echo "==> Checking Firestore contract metadata"
node tool/check_firestore_contract.mjs

echo "==> Checking Firestore data validator syntax"
node --check tool/validate_firestore_data.mjs

echo "==> Running Functions lint"
npm --prefix functions run lint

echo "==> Running Functions tests"
npm --prefix functions test

echo "==> Running Firestore rules emulator tests"
firebase emulators:exec --only firestore \
  "npm --prefix functions run test:rules"

echo "==> Running focused Flutter analysis"
flutter analyze \
  lib/run_clubs/data/run_clubs_repository.dart \
  lib/run_clubs/presentation/create/create_run_club_controller.dart \
  lib/reviews/data/reviews_repository.dart \
  lib/reviews/presentation/reviews_section.dart \
  lib/runs/data/run_repository.dart \
  lib/user_profile/data/user_profile_repository.dart \
  test/run_clubs/run_clubs_repository_test.dart \
  test/reviews/reviews_repository_test.dart \
  test/runs/run_repository_test.dart \
  test/user_profile/user_profile_repository_test.dart

echo "==> Running focused Flutter tests"
flutter test \
  test/run_clubs/run_clubs_repository_test.dart \
  test/reviews/reviews_repository_test.dart \
  test/runs/run_repository_test.dart \
  test/user_profile/user_profile_repository_test.dart

echo "Data contract checks passed."
