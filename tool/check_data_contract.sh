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

echo "==> Checking generated shared business constants"
git diff -- lib/core/business_rules.dart functions/src/shared/businessRules.ts \
  >"$before_diff"
node tool/generate_business_rules.mjs
git diff -- lib/core/business_rules.dart functions/src/shared/businessRules.ts \
  >"$after_diff"
if ! diff -u "$before_diff" "$after_diff"; then
  echo
  echo "Generated shared business constants are stale."
  echo "Run: node tool/generate_business_rules.mjs"
  exit 1
fi

echo "==> Checking schema contract sources"
node tool/validate_schema_contracts.mjs

echo "==> Checking generated schema contract outputs"
node tool/generate_schema_contracts.mjs --check
node --check tool/generated/schema_contract_validators.mjs
node tool/check_schema_type_boundaries.mjs

echo "==> Checking schema path literals"
node tool/check_schema_path_literals.mjs

echo "==> Checking demo seed contract validation"
node --check tool/seed_demo_data.mjs
node --check tool/recompute_public_profiles.mjs
node --check tool/validate_profile_decision_migration.mjs
node --check tool/backfill_profile_decisions.mjs
node --check tool/backfill_profile_photos.mjs
node --check functions/scripts/backfill-profile-thumbnails.cjs
node --test tool/seed_demo_data_append.test.mjs \
  tool/seed_demo_data_schema.test.mjs \
  tool/firebase_project_resolver.test.mjs \
  tool/recompute_public_profiles.test.mjs \
  tool/validate_profile_decision_migration.test.mjs \
  tool/backfill_profile_decisions.test.mjs \
  tool/backfill_profile_photos.test.mjs
node tool/seed_demo_data.mjs --scenario smoke --json >/dev/null

echo "==> Analyzing Firestore type generator"
dart analyze tool/generate_firestore_types.dart

echo "==> Checking Firestore contract metadata"
node tool/check_firestore_contract.mjs

echo "==> Checking Firestore data validator syntax"
node --check tool/validate_firestore_data.mjs
node --check tool/delete_firestore_reviews.mjs

echo "==> Running Functions lint"
npm --prefix functions run lint

echo "==> Running Functions tests"
npm --prefix functions test

echo "==> Checking seed and Functions profile projection parity"
node --test tool/profile_projection_parity.test.mjs

echo "==> Running Firestore rules emulator tests"
firebase emulators:exec --project demo-catch-rules --only firestore,storage \
  "npm --prefix functions run test:rules"

echo "==> Running focused Flutter analysis"
flutter analyze \
  lib/run_clubs/data/run_clubs_repository.dart \
  lib/run_clubs/presentation/create/create_run_club_controller.dart \
  lib/reviews/data/reviews_repository.dart \
  lib/reviews/presentation/reviews_section.dart \
  lib/runs/data/run_repository.dart \
  lib/user_profile/data/user_profile_repository.dart \
  test/core/schema_contracts_generated_test.dart \
  test/run_clubs/run_clubs_repository_test.dart \
  test/reviews/reviews_repository_test.dart \
  test/runs/run_repository_test.dart \
  test/user_profile/user_profile_repository_test.dart

echo "==> Running focused Flutter tests"
flutter test \
  test/core/schema_contracts_generated_test.dart \
  test/run_clubs/run_clubs_repository_test.dart \
  test/reviews/reviews_repository_test.dart \
  test/runs/run_repository_test.dart \
  test/user_profile/user_profile_repository_test.dart

echo "Data contract checks passed."
