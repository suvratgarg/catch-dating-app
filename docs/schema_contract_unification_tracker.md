---
doc_id: schema_contract_unification
version: 0.8.5
updated: 2026-05-16
owner: recursive_audit_loop
status: active
---

# Schema Contract Unification Tracker

## Read Policy

Read this before changing schema-source tooling, Dart/TypeScript model
generation, callable validation schemas, seed data generation, prompt catalogs,
Firestore contract checks, or storage-path migrations such as a future
`swipes` rename.

This document owns the long-horizon schema governance strategy. Use
`docs/firestore_functions_data_contract_tracker.md` for the current Firestore
rules, Functions ownership, and data-contract cleanup workflow, and use
`docs/demo_data_seeding.md` for day-to-day demo seeding commands.

## Purpose

The repo has reached the point where schema drift is creating product and
operational drag. The same concepts are currently declared in several places:

- Dart Freezed/json_serializable domain models.
- Dart profile validation helpers.
- Dart prompt catalogs.
- Transitional TypeScript Admin SDK interfaces in
  `functions/src/shared/firestore.ts`.
- Generated Ajv validators inside Cloud Functions.
- `tool/firestore_contract.json` ownership and field metadata.
- Firestore rules shape checks.
- Rules emulator fixtures.
- Demo seed builders.
- Live dev/staging/prod data and repair scripts.

The durable goal is not to write a bigger seeding patch. The goal is to make
schema changes cheap, compiler-visible, and hard to forget across Flutter,
Functions, rules, data validation, and seed tooling.

## Current Repo Baseline

Existing useful pieces:

- `tool/generate_firestore_types.dart` still generates the transitional
  Cloud Functions Admin SDK facade at `functions/src/shared/firestore.ts` from
  selected Dart models plus `tool/firestore_ts_overlay.json`.
- `tool/generate_schema_contracts.mjs` generates schema-owned TypeScript
  interfaces, Ajv validators, Dart constants, schema registries, and
  tool-time validators from `contracts/`.
- `tool/check_data_contract.sh` already checks generated Firestore TS types,
  generated business constants, Firestore contract metadata, validator syntax,
  Functions lint/tests, Firestore rules tests, and focused Flutter tests.
- `tool/firestore_contract.json` records collection ownership, allowed fields,
  operations, exported functions, and migration notes.
- `tool/business_rules.json` generates shared Dart and TypeScript constants.
- `lib/user_profile/domain/profile_validation.dart` owns app-side profile
  constraints today.
- `functions/src/profiles/updateUserProfile.ts` consumes generated Ajv patch
  validation today.
- `lib/user_profile/domain/profile_prompts.dart` owns the current profile/photo
  prompt catalog today.
- `tool/seed_demo_data.mjs` and `tool/demo_ops_core.mjs` own demo data and
  warm-account write plans.

Current gaps:

- Flutter production validation still consumes generated schema constants
  selectively; broad Dart schema validation is now available for contract tests,
  but app write paths are not all runtime-validated against JSON Schema.
- Full document schemas and partial update schemas are not generated from one
  contract.
- Prompt catalogs are Dart-only even though Functions and seed tools need the
  same prompt ids and limits.
- Seed data can drift into legacy or invalid shapes unless each script manually
  remembers current fields.
- Firestore rules and schema metadata are related but not generated from one
  rules compiler. Schema-derived semantic checks now cover the highest-risk
  direct-write surfaces.
- Storage/API naming migrations, such as replacing the user-facing swiping
  model with contextual catch/profile decisions, do not yet have a standard
  dual-read/dual-write migration pattern.

## External Tooling Decision

Use a contract-first stack with small Catch-specific glue instead of trying to
make Dart, TypeScript, Zod, rules, and seed scripts all be primary authorities.

Recommended canonical format:

- JSON Schema draft-07 for persisted Firestore documents, embedded objects,
  prompt catalogs, and patch payloads.
- Ajv in Node/Functions/tooling for runtime validation.
- `json-schema-to-typescript` for generated TypeScript types where useful.
- Dart `json_schema` package for tool/test-time validation and golden fixtures.
- Zod has been removed from Functions validation. New callable validation must
  be described in `contracts/callables` or `contracts/patches` and consumed via
  generated Ajv validators.

Why draft-07:

- Ajv's normal export supports draft-07 directly.
- Ajv's docs state draft-07 is the most widely used option and recommend it
  unless draft-2019-09 or 2020-12 features are actually needed.
- Draft-2019-09/2020-12 support requires a separate Ajv export and carries
  complexity/performance cost for features we do not need yet.

Why not make Zod canonical:

- Zod is excellent TypeScript ergonomics, but it does not naturally generate
  Dart validators, Firestore rules metadata, seed validation, and JSON fixtures.
- If Zod remains in the repo, it should be generated from or checked against the
  canonical schemas, not edited as the source of truth.

Why not migrate all Functions to Dart now:

- Firebase announced experimental Dart support for Cloud Functions for Firebase
  in May 2026, and the docs say it is experimental.
- The current Dart Functions limitation is important for Catch: HTTP and
  callable functions are the deployable path, while other triggers such as
  Firestore triggers can be emulated but cannot be deployed.
- Catch currently depends heavily on Firestore triggers for profile projection,
  matching, moderation, notifications, and aggregates, so TypeScript remains the
  production Functions language for now.
- Reconsider Dart Functions only after deployable Firestore/storage/scheduled
  triggers and normal client SDK callable invocation are mature enough for this
  app.

References checked on 2026-05-15:

- Firebase Dart Functions announcement:
  https://firebase.blog/posts/2026/05/dart-functions-exp
- Firebase Dart Functions getting started and limitations:
  https://firebase.google.com/docs/functions/start-dart
- Ajv schema-language guidance:
  https://ajv.js.org/guide/schema-language.html
- Ajv validator overview:
  https://ajv.js.org/

## Target Architecture

Introduce a dedicated contract layer:

```text
contracts/
  README.md
  firestore/
    users.schema.json
    public_profiles.schema.json
    swipe_decisions.schema.json
    runs.schema.json
    run_clubs.schema.json
  embedded/
    profile_prompt_answer.schema.json
    photo_prompt_answer.schema.json
    profile_signal.schema.json
  catalogs/
    profile_prompts.json
    photo_prompts.json
    running_reason_options.json
  patches/
    update_user_profile.schema.json
  migrations/
    swipes_to_profile_decisions.json
  fixtures/
    valid/
    invalid/
```

Generated outputs should live outside `contracts/` so it remains readable:

```text
functions/src/shared/generated/
  profilePromptAnswer.ts
  photoPromptAnswer.ts
  userProfileDocument.ts
  publicProfileDocument.ts
  updateUserProfileCallablePayload.ts
  schemaValidators.ts
  schemaRegistry.ts

lib/core/schema_contracts/generated/
  profile_schema_contracts.g.dart
  schema_contracts.g.dart

tool/generated/
  schema_contract_registry.mjs
  schema_contract_validators.mjs
  firestore_contract_projection.json
```

The exact paths can change during implementation if the repo structure suggests
a better fit. The important rule is that generated outputs are named as
generated outputs and are checked by CI.

## What The Contract Owns

The contract layer should own:

- Collection ids and storage paths.
- Logical document names independent of storage path.
- Full document shape.
- Patch/input payload shape.
- Embedded object shape.
- Enum values.
- Prompt catalog ids, titles, placeholders, max counts, and max lengths.
- Field nullability and optionality.
- Simple scalar limits: string lengths, array lengths, min/max numbers,
  URL/email formats where appropriate, and allowed id patterns.
- Ownership metadata: client-writable, callable-owned, trigger-owned,
  server-only, read-only projection.
- Deprecation metadata for legacy fields.
- Migration phase metadata for storage/path renames.
- Golden valid/invalid examples.

The contract layer should not own:

- Multi-document transactional business behavior.
- Rate limits.
- Notification fan-out behavior.
- Product ranking/recommendation algorithms.
- Dynamic checks that need current time, Auth state, attendance membership, or
  multiple Firestore reads.
- The full text of Firestore rules in the first pass.

Those should remain in Functions, repositories, rules, or domain services, but
they should consume generated constants and validators where possible.

## Firestore Type And Value Modeling Rules

Firestore values need explicit modeling because JSON Schema describes JSON,
while live Firestore also has `Timestamp`, server timestamps, document
references, and admin SDK sentinel values.

Contract convention:

- Persisted timestamp fields use a custom metadata annotation such as
  `x-firestore-type: "timestamp"`.
- Tooling validates serialized timestamp test fixtures as milliseconds or a
  canonical timestamp object, then adapters convert to real Firestore
  `Timestamp` values for Functions/tests.
- Server timestamp sentinels are not part of full document schemas. They belong
  to patch/write-plan adapter code.
- Document ids and path params should be first-class contract metadata, not
  ad hoc string concatenation.
- Public projections such as `publicProfiles/{uid}` should declare their source
  document and projection owner.

## Patch Schema Rules

Full documents and update patches are different contracts.

Patch schemas should:

- Be generated or derived from the relevant full document schema plus an
  explicit allowed field set.
- Enforce "at least one field" for callables like `updateUserProfile`.
- Allow only fields owned by that operation.
- Normalize input through one explicit adapter layer before writing Firestore.
- Have golden fixtures for valid patches, invalid unknown fields, invalid
  lengths, invalid enum values, and empty patch bodies.

## Prompt Catalog Rules

Profile prompts and photo prompts should move from Dart-only source to shared
contract/catalog source.

Target behavior:

- Add/edit/reorder prompt definitions in `contracts/catalogs/`.
- Generate Dart prompt catalog helpers consumed by onboarding and Edit Profile.
- Generate TypeScript prompt id constants and seed helpers.
- Validate stored prompt answers against stable ids and max lengths.
- Keep stored documents using stable prompt ids. Display copy resolves from the
  current catalog with fallback for legacy prompt text.
- Do not keep generic `bio` as a new-write field. Legacy bio content migrates
  into the `perfectRun` prompt.

## Seeder Rules

The seeder should stop hand-declaring schemas.

Target behavior:

- Seed builders use generated constants/catalog helpers.
- Every planned document is validated against the generated schema before it is
  written.
- Dry runs report schema violations with document path, field path, expected
  constraint, and the builder that emitted the bad value.
- Seed plans fail on legacy fields like `bio` after the profile-prompt migration
  is complete.
- `publicProfiles` in seed data should preferably be built by the same pure
  projection helper used by `syncPublicProfile`, or by a generated projection
  helper that is tested against the trigger behavior.
- Demo ops validation should report schema drift separately from missing demo
  state, stale run references, and expected operational gaps.

## Firestore Rules Strategy

Do not attempt a complete JSON Schema to Firestore Rules compiler in the first
pass. Firestore rules are a security language with Auth and path context, not a
general JSON Schema runtime.

First target:

- Generate field allowlists from the contract.
- Generate or check ownership metadata against `tool/firestore_contract.json`.
- Generate constants for enum values and simple limits where rules need them.
- Add contract checks that compare rules field sets against the schema field
  sets.
- Keep rules emulator tests as the behavioral proof.

Later target:

- Consider generating small rules helper snippets for repetitive scalar checks
  only after the metadata/checker path is stable.

## Future `swipes` Rename Strategy

The product model has moved away from generic left/right swiping toward
contextual catch/profile reactions. Storage can remain `swipes` temporarily,
but the contract layer should make the future migration predictable.

Migration phases:

1. `observe`: add logical contract name such as `profileDecision` while storage
   remains `swipes/{uid}/outgoing/{targetId}`.
2. `dual-read-ready`: generated path constants expose both old and new paths,
   but writes still use the old path.
3. `dual-write`: new writes populate both paths behind one repository/function
   seam.
4. `backfill`: migration script copies historical docs and verifies counts.
5. `new-primary`: reads prefer the new path with old-path fallback.
6. `freeze-old`: rules deny old-path client writes while backend repair tools
   can still read.
7. `retire-old`: remove old-path reads after production validation.

Contract metadata should include:

- logical document id,
- current storage path,
- legacy storage paths,
- migration phase,
- owner,
- source collections/triggers,
- allowed write operations,
- raw-path scanner allowlist for migration scripts only.

## CI Target

`tool/check_data_contract.sh` should eventually include these steps:

```bash
node tool/generate_schema_contracts.mjs --check
node tool/validate_schema_contracts.mjs
node --test tool/schema_contracts/*.test.mjs
dart test test/schema_contracts
node tool/seed_demo_data.mjs --scenario beta-full --json
firebase emulators:exec --only firestore "npm --prefix functions run test:rules"
```

Exact command names may change, but CI must prove:

- schemas compile,
- generated files are current,
- TypeScript validators/types compile,
- Dart generated constants/validators compile,
- golden fixtures pass in both language surfaces where applicable,
- seed dry runs cannot emit invalid documents,
- Firestore contract metadata and rules field sets remain aligned.

## Implementation Phases

### 2026-05-15: Phase 1 Profile Contract Slice

Created the first source contract layer under `contracts/`:

- `contracts/README.md`
- `contracts/shared/profile_common.schema.json`
- `contracts/catalogs/profile_prompts.json`
- `contracts/catalogs/photo_prompts.json`
- `contracts/embedded/profile_prompt_answer.schema.json`
- `contracts/embedded/photo_prompt_answer.schema.json`
- `contracts/firestore/users.schema.json`
- `contracts/firestore/public_profiles.schema.json`
- `contracts/patches/update_user_profile.schema.json`
- `contracts/fixtures/valid/*`
- `contracts/fixtures/invalid/*`

Also added `tool/validate_schema_contracts.mjs` and wired it into
`tool/check_data_contract.sh`. This is intentionally not full Ajv validation
yet. It is a no-dependency source check that parses all contract JSON, verifies
draft-07 schema metadata, checks local `$ref` targets, verifies prompt catalog
uniqueness, checks catalog/schema limit alignment, and keeps valid fixtures
free of legacy `bio`.

Current inventory findings encoded in the contract/README:

- Dart, Functions, and Firestore rules should use the contract height range of
  120-220 cm.
- Functions profile updates and Firestore rules should not accept legacy
  `sexualOrientation` on new profile writes.
- Seed output should emit structured `profilePrompts` and `photoPrompts` from
  the shared catalog rather than legacy `bio`.
- `syncPublicProfile` still hardcodes `perfectRun` prompt copy instead of
  consuming a shared prompt catalog.
- Public profile `languages` stays optional in this first contract because the
  current backend projection omits empty language arrays through
  `tool/firestore_ts_overlay.json`.

Verification:

```bash
node --check tool/validate_schema_contracts.mjs
node tool/validate_schema_contracts.mjs
```

### 2026-05-15: Phase 1A Drift Repair

Implemented the first concrete drift repairs against the Phase 1 profile
contract:

- `functions/src/profiles/updateUserProfile.ts` now validates height with the
  same 120-220 cm range as Dart and the contract.
- `functions/src/profiles/updateUserProfile.ts` no longer accepts
  `sexualOrientation` in profile update patches.
- `firestore.rules` now validates user profile height with the same 120-220 cm
  range on direct creates and retained-document shape checks.
- `firestore.rules` no longer accepts legacy `sexualOrientation` on direct
  profile creates.
- `tool/seed_demo_data.mjs` no longer writes legacy `bio`; synthetic users and
  public profile projections now carry `profilePrompts`, `photoPrompts`, and
  `preferredRunTimes`.
- `tool/seed_demo_data.mjs` reads prompt copy from
  `contracts/catalogs/profile_prompts.json` and
  `contracts/catalogs/photo_prompts.json`.
- `tool/validate_schema_contracts.mjs` now includes transitional drift checks
  for generated callable schema validation, callable `sexualOrientation`
  removal, rules height bounds, and seed output free of new-write `bio`.

Data-shape decision made during this pass:

- Do not migrate persisted `photoUrls`, `photoThumbnailUrls`, and
  `photoPrompts` into a nested photo object in this slice. From a greenfield
  design, a `ProfilePhoto` object with `url`, `thumbnailUrl`, `prompt`,
  `storagePath`, and moderation metadata is cleaner. In this codebase, however,
  the current parallel arrays are used by upload controllers, public profile
  projection, thumbnail generation, moderation cleanup, account deletion, and
  avatar surfaces. Changing the storage shape here would turn a constraint
  repair into a full production data migration. Track it as a deliberate
  future migration with backfill and dual-read support.

### 2026-05-15: Phase 2 Generator Scaffolding

Implemented the first deterministic generated-output layer:

- Added Functions dependencies:
  - `ajv`
  - `ajv-formats`
  - `json-schema-to-typescript`
- Added Dart dev/tool dependency:
  - `json_schema`
- Added `tool/generate_schema_contracts.mjs`.
- Generated TypeScript contract types in
  `functions/src/shared/generated/*Document.ts`,
  `functions/src/shared/generated/*PromptAnswer.ts`, and
  `functions/src/shared/generated/updateUserProfileCallablePayload.ts`.
- Generated Ajv-backed Functions validators in
  `functions/src/shared/generated/schemaValidators.ts`.
- Generated bundled schema registries in
  `functions/src/shared/generated/schemaRegistry.ts` and
  `tool/generated/schema_contract_registry.mjs`.
- Generated tool-side Ajv validators in
  `tool/generated/schema_contract_validators.mjs` for seed/demo tooling.
- Generated Dart prompt catalog, limit, and schema constants in
  `lib/core/schema_contracts/generated/profile_schema_contracts.g.dart`.
- Added `--check` mode to fail when generated schema outputs are stale.
- Added `functions/src/shared/schemaContracts.test.ts` to compile generated
  validators and prove valid/invalid contract fixtures.
- Added `test/core/schema_contracts_generated_test.dart` to prove generated
  Dart constants and prompt schemas compile/validate.
- Wired generated-output checks and the Dart generated-contract test into
  `tool/check_data_contract.sh`.

Verification:

```bash
node tool/generate_schema_contracts.mjs --check
npm --prefix functions run build
npm --prefix functions run lint
node --test functions/lib/shared/schemaContracts.test.js
flutter test test/core/schema_contracts_generated_test.dart
./tool/check_data_contract.sh
```

Result: all passed on 2026-05-15.

Auxiliary work identified during Phase 2:

- `lib/user_profile/domain/profile_prompts.dart` still hand-declares the prompt
  catalog. Phase 3 should make the app consume generated catalog constants or
  add an adapter that prevents prompt-copy drift.
- `lib/user_profile/domain/profile_validation.dart` still hand-declares profile
  limits. Phase 3 should consume generated limit constants for prompt lengths,
  height bounds, age bounds, and any future enum/list caps.
- `functions/src/profiles/updateUserProfile.ts` still uses handwritten Zod.
  Phase 3 should either migrate it to the generated Ajv validator or add a
  transitional parity test between Zod and JSON Schema.
- `tool/seed_demo_data.mjs` reads contract JSON directly today. Phase 4 should
  switch it to generated tool validators/helpers and validate every planned
  profile/public profile write before applying.
- `functions/src/profiles/syncPublicProfile.ts` still hardcodes
  `perfectRun`-related prompt fallback behavior. Phase 5 should move this to a
  generated/shared catalog helper.
- `pubspec.yaml` and `pubspec.lock` already had unrelated removal of
  `flutter_card_swiper` before Stage 2. The Stage 2 dependency addition shares
  those dirty files, so isolate carefully if committing this slice.

### 2026-05-15: Phase 3 Profile Validation Convergence

Moved the profile update callable and Dart profile helpers onto the generated
contract layer:

- `functions/src/profiles/updateUserProfile.ts` now validates callable payloads
  with `validateUpdateUserProfileCallablePayload` from the generated Ajv
  validator instead of a handwritten Zod schema.
- Profile update normalization is now explicit in the callable adapter:
  trimmed profile strings, normalized `@instagram` handles, trimmed enum-array
  values, trimmed prompt ids/titles, prompt blank-line collapsing, empty prompt
  filtering, and `dateOfBirth` millis-to-Timestamp conversion remain tested.
- `contracts/firestore/users.schema.json` and
  `contracts/patches/update_user_profile.schema.json` now model email as empty
  string or `format: email`, matching the Dart optional-email behavior while
  rejecting malformed non-empty emails in Functions.
- `contracts/fixtures/invalid/update_user_profile_invalid_email.json` adds a
  shared invalid email vector.
- `lib/user_profile/domain/profile_validation.dart` now imports generated
  profile age, height, and prompt-length constants.
- `lib/user_profile/domain/profile_prompts.dart` now builds app-facing prompt
  definitions from the generated prompt catalogs instead of hard-declaring
  prompt ids, titles, placeholders, and max counts.
- `functions/src/shared/schemaContracts.test.ts` and
  `test/core/schema_contracts_generated_test.dart` both validate shared
  contract fixtures.
- `tool/validate_schema_contracts.mjs` now checks that `updateUserProfile`
  remains on generated schema validation rather than checking for old local
  height constants.

Verification:

```bash
node tool/generate_schema_contracts.mjs --check
node tool/validate_schema_contracts.mjs
npm --prefix functions run build
npm --prefix functions run lint
node --test functions/lib/profiles/updateUserProfile.test.js functions/lib/shared/schemaContracts.test.js
flutter analyze lib/user_profile/domain/profile_validation.dart lib/user_profile/domain/profile_prompts.dart test/core/schema_contracts_generated_test.dart test/user_profile/user_profile_domain_test.dart
flutter test test/core/schema_contracts_generated_test.dart test/user_profile/user_profile_domain_test.dart
```

Result: all focused Phase 3 checks passed on 2026-05-15.

Auxiliary work identified during Phase 3:

- Firestore rules semantic drift is now checked for `users`, contextual profile
  decisions, and saved runs. Further rules work should add schema-derived
  checks for any new direct-write surface before it is opened to clients.
- The broad generated Dart schema registry is intentionally kept separate from
  the lightweight profile constants file used by production UI. If it grows much
  further, split generated prompt catalogs, validation limits, and schema maps
  into separate generated files.
- `updateUserProfile` now rejects malformed non-empty emails and invalid enum
  strings server-side. Any old seeded/demo data with invalid non-empty email
  values should be repaired before production enforcement is broadened to full
  document validation.

### 2026-05-15: Phase 4 Seeder Contract Enforcement

Moved demo profile seeding onto the generated contract layer:

- `tool/generated/schema_contract_registry.mjs` now exports generated prompt
  catalogs, prompt limits, and default prompt ids in addition to bundled JSON
  Schemas.
- `tool/seed_demo_data.mjs` consumes those generated catalogs instead of
  reading `contracts/catalogs` directly.
- The seed tool validates every planned `users/{uid}` and
  `publicProfiles/{uid}` document before summary output or writes.
- Seed validation serializes Firestore Timestamp values into the shared schema
  fixture shape before Ajv validation.
- Seed validation now separates stale catalog failures from schema-shape
  failures: unknown prompt ids and prompt-title mismatches fail with explicit
  catalog errors, while malformed documents fail with schema paths.
- Profile contracts now explicitly allow internal demo metadata fields used by
  seeded profile documents: `synthetic`, `seedPrefix`, `scenario`, `demoOps`,
  `demoOpsId`, and `demoOpsCommand`.
- `tool/seed_demo_data_schema.test.mjs` covers valid seeded profile docs,
  legacy `bio` rejection, stale prompt id rejection, and overlong prompt answer
  rejection.
- `tool/check_data_contract.sh` now runs seed schema tests plus a smoke
  scenario dry run so profile-shaped seed drift fails locally and in CI.

Verification:

```bash
node tool/generate_schema_contracts.mjs --check
node tool/validate_schema_contracts.mjs
node --test tool/seed_demo_data_append.test.mjs tool/seed_demo_data_schema.test.mjs
node tool/seed_demo_data.mjs --scenario smoke --json
```

Result: all focused Phase 4 checks passed on 2026-05-15.

Auxiliary work identified during Phase 4:

- Public-profile projection equality is intentionally left for Phase 5. Phase 4
  validates shape/catalog correctness; Phase 5 should compare seeded/stored
  public profile data against the canonical `users -> publicProfiles`
  projection helper.
- Demo operations read existing `users` and `publicProfiles` documents but do
  not currently create or update profile documents directly. If future demo
  operations warm profile docs, route them through `validateSeedProfileDocuments`
  or the same generated validator layer before writes.

### 2026-05-15: Phase 5 Projection Helper Convergence

Centralized the Functions-side public-profile projection and added seed parity
checks:

- `functions/src/shared/profileProjection.ts` now exports the pure
  `publicProfileFromUserProfileDoc` helper alongside `publicDisplayName` and
  `publicAvatarUrl`.
- Prompt normalization, photo-prompt normalization, legacy-bio fallback, and
  blank-line collapsing moved out of the Firestore trigger and into the pure
  projection helper.
- `functions/src/profiles/syncPublicProfile.ts` now uses the pure projection
  helper before writing `publicProfiles/{uid}` and before syncing hosted-club
  and review denormalized names.
- `functions/src/shared/demoMetadata.ts` now includes `scenario` and no longer
  materializes undefined demo metadata fields.
- Public profile sync now preserves internal demo metadata (`synthetic`,
  `seedPrefix`, `scenario`, `demoOps*`) when those fields exist on demo user
  documents, preventing seeded public profiles from losing cleanup markers if a
  trigger reprojects them.
- `tool/seed_demo_data.mjs` now compares each planned synthetic
  `publicProfiles/{uid}` doc against the seeded `users/{uid}` projection before
  writing.
- `tool/profile_projection_parity.test.mjs` compares the seed projection helper
  against the compiled Functions projection helper so the two implementations
  cannot drift silently.
- `functions/src/shared/profileProjection.test.ts` covers display-name
  fallbacks, prompt/photo normalization, legacy-bio migration, and demo metadata
  propagation.
- `tool/check_data_contract.sh` now runs projection parity after Functions
  build/tests.

Verification:

```bash
npm --prefix functions run build
npm --prefix functions run lint
node --test functions/lib/profiles/syncPublicProfile.test.js functions/lib/shared/profileProjection.test.js functions/lib/shared/schemaContracts.test.js
node --test tool/seed_demo_data_append.test.mjs tool/seed_demo_data_schema.test.mjs
node --test tool/profile_projection_parity.test.mjs
node tool/seed_demo_data.mjs --scenario smoke --json
```

Result: focused Phase 5 checks passed on 2026-05-15.

Auxiliary work identified during Phase 5:

- Repair/backfill tooling for existing stale public profiles was completed in
  the next Phase 5 subtask. Live environment apply remains intentionally
  operator-driven.
- If we later want the seed tool to directly import the Functions projection
  helper instead of parity-testing a mirrored JS helper, we need a source-level
  shared JS/TS packaging boundary. The current approach avoids requiring a
  Functions build before ordinary seed dry runs.

### 2026-05-15: Phase 5 Public Profile Repair Tooling

Added the dry-run-first repair surface for existing public profile drift:

- `tool/recompute_public_profiles.mjs` scans `users` and `publicProfiles`,
  projects each complete active user through the compiled Functions
  `publicProfileFromUserProfileDoc` helper, validates the expected projection
  with the generated public-profile schema validator, and plans repairs.
- The repair tool plans full `set` replacements for stale or missing
  `publicProfiles/{uid}` documents so legacy fields like `bio`,
  `latitude`, or `longitude` are removed rather than left behind.
- The repair tool plans deletes for public profiles whose users are deleted or
  underage, warns on incomplete users that still have public profiles, and
  warns on orphan public profiles without matching users.
- Production apply is guarded: `--apply` against prod requires `--allow-prod`.
- `tool/recompute_public_profiles.test.mjs` covers stale projection repair,
  missing projection creation, deleted-user cleanup, incomplete/orphan
  warnings, and batch apply behavior.
- `tool/check_data_contract.sh` now syntax-checks the repair tool and runs its
  tests.

Verification:

```bash
node --check tool/recompute_public_profiles.mjs
node --test tool/recompute_public_profiles.test.mjs
```

Result: focused repair-tool checks passed on 2026-05-15.

How to run the repair manually:

```bash
npm --prefix functions run build
node tool/recompute_public_profiles.mjs --env dev --json
node tool/recompute_public_profiles.mjs --env dev --apply
node tool/recompute_public_profiles.mjs --env staging --json
node tool/recompute_public_profiles.mjs --env staging --apply
node tool/recompute_public_profiles.mjs --env prod --json
node tool/recompute_public_profiles.mjs --env prod --apply --allow-prod
```

### 2026-05-15: Phase 5 Profile Photo Migration Scope

Scoped the future profile photo storage migration without changing the live
model:

- Added `contracts/migrations/profile_photos_storage.json` as the durable
  migration brief for replacing `photoUrls`, `photoThumbnailUrls`, and
  `photoPrompts` parallel arrays with stable `ProfilePhoto` objects.
- Defined the target `ProfilePhoto` object shape: stable photo id, full and
  thumbnail URLs, storage paths, prompt/caption metadata, moderation status,
  position, and lifecycle timestamps.
- Listed known consumers that must move together: edit profile photo UI,
  profile insights, thumbnail generation, public-profile projection, profile
  update callable/schema, and public/user profile contracts.
- Locked in a dual-read/dual-write/backfill/new-primary/retire-legacy sequence
  so we do not mix a data-model migration with a profile UI rewrite.

### 2026-05-15: Phase 7 Profile Photo Storage Metadata Contract

Introduced the storage-object metadata contract for the future `ProfilePhoto`
migration without switching live reads or writes:

- Added `contracts/embedded/profile_photo.schema.json`, grouping stable photo
  id, full/thumbnail URLs, full/thumbnail Storage object paths, prompt metadata,
  moderation state, position, and lifecycle timestamps.
- Added valid and invalid fixtures for the future `ProfilePhoto` shape,
  including a guard against leading-slash Storage object paths.
- Generated TypeScript, tool, and Dart schema outputs for `ProfilePhoto` so
  future dual-read/dual-write work can consume the same contract instead of
  re-declaring the shape.
- Linked `contracts/migrations/profile_photos_storage.json` to the embedded
  `ProfilePhoto` contract.

Result: design/scope complete; no live model migration has started.

### 2026-05-15: Phase 10 Profile Photo Dual-Read/Dual-Write Migration

Started the live `ProfilePhoto` migration that had previously only been
scoped:

- Added a Dart `ProfilePhoto` domain object and threaded optional
  `profilePhotos` through `UserProfile` and `PublicProfile` while preserving
  the legacy `photoUrls`, `photoThumbnailUrls`, and `photoPrompts` arrays.
- Added effective-photo getters so profile rendering and avatar-scale reads
  prefer grouped `profilePhotos` and synthesize grouped objects from legacy
  arrays for old documents.
- Updated uploads to write grouped `profilePhotos` plus the legacy arrays in
  the same profile update callable payload.
- Updated photo prompt edits, thumbnail generation, moderation deletion,
  public-profile projection, seed generation, and projection repair tooling to
  keep grouped photos and legacy arrays in sync.
- Added `tool/backfill_profile_photos.mjs`, a dry-run-first migration tool that
  derives grouped photos from legacy arrays, validates each `ProfilePhoto`
  against the generated schema, and can repair `users/{uid}` plus
  `publicProfiles/{uid}` with `--apply`.
- Updated `contracts/migrations/profile_photos_storage.json` from
  design-scoped to `dual_write_backfill_ready`.

Result: `profilePhotos` is now a real optional document field with
dual-read/dual-write support. Legacy arrays remain intentionally present for
the current app build and can be retired only after forced-update coverage is
acceptable.

Follow-up closed on 2026-05-16:

- Account deletion now deletes Storage objects referenced by grouped
  `profilePhotos`, clears the grouped field, and still clears the legacy photo
  arrays.
- The legacy thumbnail backfill script now updates grouped `profilePhotos` when
  it generates missing thumbnails, while continuing to maintain
  `photoThumbnailUrls` for compatibility.
- Edit Profile photo grid and photo-caption rows now render through
  `effectiveProfilePhotos` instead of reading `photoUrls` directly.
- `tool/check_data_contract.sh` now syntax-checks the thumbnail backfill script
  and runs the profile-photo backfill tests.
- `tool/backfill_profile_photos.mjs` now resolves Firebase project aliases from
  `.firebaserc` through a shared resolver, instead of hardcoding invented dev,
  staging, and prod project ids.
- Live migration was applied after deploying the updated profile Functions:
  - dev: 74 users scanned, 74 grouped-photo users after apply, 0 repairs and
    0 warnings on the final dry run.
  - staging: 0 users scanned, 0 repairs and 0 warnings after Functions deploy.
  - prod: 86 users scanned, 86 grouped-photo users after apply, 0 repairs and
    0 warnings on the final dry run.
- Important sequencing rule: deploy the updated `syncPublicProfile` projection
  before applying the user backfill. Otherwise, the currently deployed trigger
  can rewrite `publicProfiles/{uid}` back to the legacy projection after the
  user document update.

Proof:

```bash
npm --prefix functions run build
npm --prefix functions run lint
dart analyze lib/user_profile/domain/profile_photo.dart lib/user_profile/domain/user_profile.dart lib/public_profile/domain/public_profile.dart lib/image_uploads/data/image_upload_repository.dart lib/image_uploads/presentation/photo_upload_controller.dart lib/swipes/presentation/profile_card_content.dart lib/user_profile/presentation/widgets/profile_tab.dart lib/user_profile/presentation/widgets/profile_inline_editors.dart
node tool/validate_schema_contracts.mjs
node tool/check_firestore_contract.mjs
node --test tool/backfill_profile_photos.test.mjs tool/recompute_public_profiles.test.mjs tool/profile_projection_parity.test.mjs tool/seed_demo_data_schema.test.mjs tool/seed_demo_data_append.test.mjs
node --test functions/lib/safety/accountDeletion.test.js
./tool/check_data_contract.sh
./tool/firebase_with_env.sh dev deploy --only functions:syncPublicProfile,functions:updateUserProfile,functions:generateProfilePhotoThumbnail,functions:moderatePhotoOnUpload,functions:requestAccountDeletion --non-interactive
./tool/firebase_with_env.sh staging deploy --only functions:syncPublicProfile,functions:updateUserProfile,functions:generateProfilePhotoThumbnail,functions:moderatePhotoOnUpload,functions:requestAccountDeletion --non-interactive
./tool/firebase_with_env.sh prod deploy --only functions:syncPublicProfile,functions:updateUserProfile,functions:generateProfilePhotoThumbnail,functions:moderatePhotoOnUpload,functions:requestAccountDeletion --non-interactive
node tool/backfill_profile_photos.mjs --env dev --apply
node tool/backfill_profile_photos.mjs --env dev
node tool/backfill_profile_photos.mjs --env staging
node tool/backfill_profile_photos.mjs --env prod --apply --allow-prod
node tool/backfill_profile_photos.mjs --env prod
```

### 2026-05-15: Generator Boundary Cleanup

Resolved the immediate duplicate-generator ambiguity without pretending the
Admin SDK typing facade can be deleted in the same step:

- `contracts/` and `tool/generate_schema_contracts.mjs` are the canonical
  source for persisted field shape, callable payload schemas, prompt catalogs,
  generated Ajv validators, generated schema registries, and Dart schema
  constants.
- `functions/src/shared/firestore.ts` is now documented as a transitional
  Cloud Functions Admin SDK facade for code that reads and writes live
  `FirebaseFirestore.Timestamp` values.
- `tool/firestore_ts_overlay.json` should only carry transitional Admin SDK or
  server-only typing gaps. New persisted fields should start in JSON Schema and
  be projected into this facade only while Functions code still imports it.
- `functions/README.md` now points new callable validation work to generated
  Ajv validators instead of the removed Zod path.

Remaining work: replace the Dart-driven Admin SDK facade with a schema-driven
Admin SDK type generator, or migrate Function imports to generated schema types
plus explicit Firestore runtime adapters. That is a separate refactor because
the current generated document types intentionally model serialized fixture
timestamps rather than live Admin SDK timestamp instances.

Follow-up closed on 2026-05-16:

- Added `tool/check_schema_type_boundaries.mjs` and wired it into
  `tool/check_data_contract.sh`.
- `tool/firestore_ts_overlay.json` now has `schemaOwnedExceptions`; any
  schema-owned field override or embedded type duplicated for the transitional
  Admin SDK facade must carry a concrete reason.
- `functions/src/shared/firestore.ts` now describes itself in the generated
  header as a transitional Admin SDK typing facade, not canonical schema truth.

Remaining work stays the same: generate this Admin SDK facade from contracts or
delete it after Function imports stop depending on live `FirebaseFirestore`
timestamp-oriented document interfaces.

### 2026-05-16: Firestore Contract Shape Slimming

Moved `tool/firestore_contract.json` closer to the intended boundary:

- Removed duplicated `allFields` lists from every collection entry now covered
  by `contracts/firestore/*.schema.json`.
- Updated `tool/check_firestore_contract.mjs` so effective collection fields are
  derived from JSON Schema properties minus schema-owned internal demo fields.
- Kept operation/ownership field groups such as `clientWritableFields`,
  `callableOwnedFields`, `triggerOwnedFields`, and `serverOwnedFields` in
  `tool/firestore_contract.json`, because JSON Schema does not express those
  write-boundary semantics directly yet.
- Kept the rules allow-list drift check, but it now compares
  `firestore.rules` against schema-derived fields instead of a duplicated
  contract-side `allFields` array.

Proof:

```bash
node tool/check_firestore_contract.mjs
```

Remaining work: derive more of the ownership/write-boundary metadata from
schema annotations if the schemas gain explicit `x-client-writable`,
`x-callable-owned`, or `x-trigger-owned` metadata.

### 2026-05-16: Profile Rules Bound Tightening

Closed the focused Phase 6 emulator gap for schema-owned profile bounds:

- Added Firestore rules helpers for optional list size limits.
- Tightened direct `users/{uid}` create shape checks for profile prompt, photo,
  interest, language, preferred distance, running reason, preferred run-time,
  and age preference bounds.
- Added rules emulator coverage for the new profile list and age-preference
  limits. The tests intentionally split max-size success cases across small
  documents to avoid the Firestore rules expression ceiling while still proving
  each tightened boundary.

Proof:

```bash
node --check functions/test/firestore.rules.test.cjs
node tool/check_firestore_contract.mjs
firebase emulators:exec --project demo-catch-rules --only firestore,storage "npm --prefix functions run test:rules"
```

Result: 61 Firestore/storage rules tests passed on 2026-05-16.

### 2026-05-16: Phase 6 Rules Semantics And Dart Schema Symmetry

Closed the two asymmetric schema-governance gaps that were still worth handling
before closing the loop:

- Added `tool/check_firestore_rules_semantics.mjs`, a schema-derived Firestore
  Rules semantic checker for the direct-write surfaces that rules still own:
  owner profile create, contextual profile decision create, and saved-run
  create.
- Wired that checker into `./tool/check_data_contract.sh` so stale rules
  literals fail the same gate as stale generated outputs.
- Tightened `users/{uid}` direct create rules so schema-required fields
  (`firstName`, `lastName`, `photoThumbnailUrls`, `photoPrompts`, and
  `preferredRunTimes`) are required in rules, not only in JSON Schema/Dart.
- Generated a broad Dart schema registry at
  `lib/core/schema_contracts/generated/schema_contracts.g.dart`, while keeping
  the existing lightweight `profile_schema_contracts.g.dart` file for
  production profile constants.
- Expanded `test/core/schema_contracts_generated_test.dart` to validate
  representative Firestore documents, callable payloads, and direct client
  writes through the generated Dart registry.

Proof:

```bash
node tool/check_firestore_rules_semantics.mjs
flutter test test/core/schema_contracts_generated_test.dart
./tool/check_data_contract.sh
```

Result: full data-contract gate passed on 2026-05-16.

### 2026-05-15: Phase 6 Ownership/Rules Drift Checks

Added schema-to-ownership checks around profile field lists:

- `tool/firestore_contract.json` now records `internalDemoFields` separately
  for `users` and `publicProfiles`. These fields are allowed in JSON schema for
  admin/demo cleanup metadata, but intentionally remain outside the Dart/TS app
  model field lists.
- `tool/check_firestore_contract.mjs` now compares `users` and
  `publicProfiles` JSON Schema properties against the ownership contract,
  excluding only the declared internal demo fields.
- The same checker compares `firestore.rules`
  `hasValidUserShape(...).hasOnly(...)` against
  `tool/firestore_contract.json` `users.allFields`, so adding/removing a
  profile field cannot silently skip the rules allow-list.

Verification:

```bash
node tool/check_firestore_contract.mjs
```

Result: focused ownership/rules drift check passed on 2026-05-15.

### 2026-05-15: Phase 7 Run Domain Contract Slice

Expanded the contract layer beyond profiles into the core run domain:

- Added run-domain schemas:
  - `contracts/shared/run_common.schema.json`
  - `contracts/firestore/run_clubs.schema.json`
  - `contracts/firestore/run_club_memberships.schema.json`
  - `contracts/firestore/runs.schema.json`
  - `contracts/firestore/run_participations.schema.json`
  - `contracts/firestore/saved_runs.schema.json`
- Added valid fixtures for run clubs, memberships, runs, run participations,
  and saved runs.
- Added an invalid run fixture for stale pace enum drift.
- Extended `tool/generate_schema_contracts.mjs` so the generated TypeScript and
  tool-side Ajv validators include run-domain document validators.
- Generalized `tool/check_firestore_contract.mjs` so every schema under
  `contracts/firestore` with `x-firestore-collection` is compared against
  `tool/firestore_contract.json`.
- Added internal demo metadata to the run-domain ownership contract so seeded
  documents remain valid while app model field lists stay clean.
- Extended seed validation from profile-only checks to run-domain checks:
  `runClubs`, `runClubMemberships`, `runs`, `runParticipations`, and
  `savedRuns` are validated before write plans can be applied.

Verification:

```bash
node tool/validate_schema_contracts.mjs
node tool/check_firestore_contract.mjs
node tool/seed_demo_data.mjs --scenario smoke --json
npm --prefix functions run build
node --test functions/lib/shared/schemaContracts.test.js
node --test tool/seed_demo_data_append.test.mjs tool/seed_demo_data_schema.test.mjs tool/recompute_public_profiles.test.mjs
```

Result: focused Phase 7 run-domain checks passed on 2026-05-15.

### 2026-05-15: Phase 7 Social, Payment, And Safety Contract Slice

Expanded the remaining high-risk generated/seeded document contracts:

- Added schemas for:
  - `payments`
  - current `swipes` storage with logical `profileDecision` metadata
  - `matches`
  - `chat_messages`
  - `activity_notifications`
  - `reviews`
  - `blocks`
  - `reports`
  - `moderationFlags`
- Added valid contract fixtures for each of the new document types.
- Added an invalid contextual decision fixture for stale
  `reactionTargetType` drift.
- Extended generated TypeScript/tool-side Ajv validators to include these
  document contracts.
- Extended seed validation to validate planned payments, decisions, matches,
  messages, reviews, and activity notifications before any write plan can be
  applied.
- Added contract metadata for the future `swipes` rename by recording the
  logical name as `profileDecision` while leaving storage unchanged.

Verification:

```bash
node tool/validate_schema_contracts.mjs
node tool/check_firestore_contract.mjs
npm --prefix functions run build
node --test functions/lib/shared/schemaContracts.test.js
node --test tool/seed_demo_data_schema.test.mjs
node tool/seed_demo_data.mjs --scenario smoke --json
```

Result: focused Phase 7 social/payment/safety checks passed on 2026-05-15.

### 2026-05-15: Phase 7 Operational Document Contract Slice

Closed the remaining lightweight document contracts that support the main app
data graph and demo tooling:

- Added schemas and fixtures for:
  - `config/cities`
  - `onboarding_drafts/{uid}`
  - `runClubHostClaims/{uid}`
  - `runClubScheduleLocks/{lockId}`
  - `userRunScheduleLocks/{lockId}`
  - `deletedUsers/{uid}`
  - `rateLimits/{docId}`
  - `functionEventReceipts/{receiptId}`
  - `seedRuns/{manifestId}`
- Added explicit server-only Firestore rules match blocks for `seedRuns`,
  `runClubScheduleLocks`, and `userRunScheduleLocks`; this preserves existing
  default-deny behavior while making the ownership contract explicit.
- Updated `tool/firestore_contract.json` so every Firestore schema with
  `x-firestore-collection` has matching ownership metadata and field sets.
- Kept onboarding drafts intentionally extensible while still recording the
  current Dart draft fields and the rules-required `step` field.
- Extended generated Functions/tool validators to cover every schema spec.
- Refactored `tool/generate_schema_contracts.mjs` so schema registries and
  validators are derived from the schema spec list instead of a hand-maintained
  export list.
- Extended seed validation to cover schedule lock write plans and the
  `seedRuns/{manifestId}` manifest before apply.

Verification:

```bash
node tool/validate_schema_contracts.mjs
node tool/check_firestore_contract.mjs
node --test tool/seed_demo_data_schema.test.mjs
npm --prefix functions run build
node --test functions/lib/shared/schemaContracts.test.js
```

Result: focused Phase 7 operational-document checks passed on 2026-05-15.

### 2026-05-15: Phase 8 Callable Payload Contract Slice

Moved callable request validation off handwritten Zod schemas and onto the
generated JSON Schema/Ajv contract layer:

- Added callable payload schemas and valid/invalid fixtures for:
  - `updateUserProfile` (already completed in Phase 3)
  - run-club create/update/archive/delete
  - run-club join/leave and per-club notification preference
  - run create/update/cancel/delete
  - run signup, signup cancellation, waitlist join/leave, attendance, and
    self-check-in payloads
  - review create/update/delete
  - block/unblock/report safety actions
  - Razorpay order creation and payment verification
  - Places autocomplete and place details
- Refactored `tool/generate_schema_contracts.mjs` so schema registries and
  validators are generated from the schema spec list rather than handwritten
  export lists.
- Added `validateCallableWithAjv` and small explicit normalizer helpers so
  trimming remains visible at callable boundaries while validation is generated.
- Removed the final Functions Zod call sites and uninstalled `zod` from the
  Functions package.

Verification:

```bash
node tool/generate_schema_contracts.mjs --check
node tool/validate_schema_contracts.mjs
npm --prefix functions run build
npm --prefix functions run lint
node --test functions/lib/runClubs/*.test.js functions/lib/runs/*.test.js functions/lib/reviews/*.test.js functions/lib/safety/*.test.js functions/lib/payments/*.test.js functions/lib/shared/schemaContracts.test.js
```

Result: focused callable payload checks passed on 2026-05-15.

### 2026-05-15: Phase 8 Direct Client Write Operation Slice

Closed the remaining generated operation-schema gap for client-owned Firestore
writes that are intentionally not callables:

- Added direct client-write schemas and valid fixtures for:
  - contextual profile decision create on the current `swipes` storage path,
  - chat message create,
  - saved-run create/delete,
  - activity notification read-state update,
  - match unread-count reset.
- Added invalid fixtures for an empty text-only chat message and an unread
  reset that tries to update more than one participant counter.
- Extended generated Functions/tool validators to include these client-write
  operation contracts.
- Tightened chat message rules so direct writes can no longer create an empty
  message unless an image URL is present.
- Aligned the `swipes` document contract with the app/rules reaction limits:
  reaction target id and label are bounded at 80 characters, preview and
  comment are bounded at 240 characters.

Verification:

```bash
node tool/generate_schema_contracts.mjs
node tool/validate_schema_contracts.mjs
npm --prefix functions run build
npm --prefix functions run lint
node --test functions/lib/shared/schemaContracts.test.js
firebase emulators:exec --project demo-catch-rules --only firestore,storage "npm --prefix functions run test:rules"
```

Result: focused direct client-write operation checks passed on 2026-05-15.

### 2026-05-15: Phase 9 Storage/API Rename Guard Slice

Started the future `swipes` storage rename safely without moving live data:

- Kept the current storage path as `swipes/{userId}/outgoing/{targetId}`.
- Selected `profileDecisions` as the future storage name for the eventual
  rename because it matches the actual product behavior better than swipes
  while staying backend-neutral.
- Added generated schema path constants for the current contextual
  profile-decision collection, outgoing subcollection, trigger path, and
  logical name.
- Moved production Dart and Functions code off raw `swipes`/`outgoing` storage
  literals for profile decisions.
- Added `tool/check_schema_path_literals.mjs` and wired it into
  `./tool/check_data_contract.sh` so new production raw path literals fail the
  contract gate.
- Added `contracts/migrations/swipes_to_profile_decisions.json` with the
  observe, dual-read, dual-write, backfill, new-primary, freeze-old, and
  retire-old phases.

Verification:

```bash
node tool/generate_schema_contracts.mjs
node tool/check_schema_path_literals.mjs
```

Result: focused path-literal guard checks passed on 2026-05-15.

### 2026-05-15: Phase 9 Migration Count Validation Slice

Closed the pre-apply validation gap for the eventual `swipes` ->
`profileDecisions` storage rename without moving live data:

- Added `tool/validate_profile_decision_migration.mjs`, a dry-run-only validator
  that reads the current and future profile-decision storage paths, validates
  both sides against the generated `SwipeDocument` schema, and compares missing,
  stale, and extra future documents.
- Added `--require-parity` so a future migration gate can fail non-zero until
  the current and future storage paths match exactly.
- Added path/document-id consistency checks so `swiperId` must match the owner
  document and `targetId` must match the outgoing decision document.
- Added focused unit coverage for missing/stale/extra docs, invalid decision
  payloads, path-id drift, and Firestore timestamp normalization.
- Wired the validator syntax check and test into `./tool/check_data_contract.sh`.

Verification:

```bash
node --check tool/validate_profile_decision_migration.mjs
node --test tool/validate_profile_decision_migration.test.mjs
```

Result: focused migration validation checks passed on 2026-05-15.

### 2026-05-15: Phase 9 Dual-Write And Backfill Tooling Slice

Advanced the profile-decision rename from observe-only to dual-write support:

- Generated current and future profile-decision path constants from the schema
  and migration contract.
- Updated `SwipeRepository` to read the union of legacy `swipes` and future
  `profileDecisions`, and to batch-write new decisions to both paths.
- Added Firestore rules for `profileDecisions/{userId}/outgoing/{targetId}`
  using the same validation and eligibility logic as legacy `swipes`.
- Kept `onSwipeCreated` attached to the legacy `swipes` trigger path so mirrored
  future writes do not duplicate match creation.
- Added `tool/backfill_profile_decisions.mjs`, a dry-run-first migration tool
  that copies missing or stale legacy decisions into `profileDecisions` without
  deleting either path.

Verification:

```bash
node --test tool/backfill_profile_decisions.test.mjs
flutter test test/swipes/swipe_repository_test.dart test/core/schema_contracts_generated_test.dart
```

Result: focused dual-write and backfill-tool checks passed on 2026-05-15.

Live environment backfill/parity result on 2026-05-15:

- Dev: current `swipes` decisions 0, future `profileDecisions` decisions 0,
  parity validator passed with `--require-parity`.
- Staging: current decisions 0, future decisions 0, parity validator passed
  with `--require-parity`.
- Prod: current decisions 0, future decisions 0, parity validator passed with
  `--require-parity`.
- No backfill writes were needed in any environment. Rerun the parity validator
  immediately before any future trigger cutover because old app builds can still
  write only the legacy `swipes` path until dual-write clients are deployed.

### 2026-05-15: Release Build Gate For Profile-Decision Cutover

Recorded the app-release gate for the eventual `swipes` ->
`profileDecisions` trigger cutover:

- Current release candidate build is `1.0.0+2`.
- After the compatible binary is available to users, Remote Config can set
  `min_build_ios = 2` and `min_build_android = 2` for the released platforms.
- The force-update gate can reduce the old-client compatibility window, but the
  backend trigger cutover still requires a final
  `tool/validate_profile_decision_migration.mjs --require-parity` pass after
  the gate is active.
- Keep dual-read/dual-write code and the legacy `swipes` trigger source until
  that post-release parity check passes.

### Phase 0: Tracker And Strategy

Status: complete.

Tasks:

- [x] Create this durable tracker.
- [x] Link the tracker from `docs/README.md`.
- [x] Add audit registry doc metadata.

Future hook:

- Add this doc to any schema/pass backlog once implementation starts.

Verification:

- Markdown/documentation only for this phase.
- Validate JSON metadata after edits.

### Phase 1: Inventory And First Contract Slice

Status: complete.

Scope:

- `users/{uid}`
- `publicProfiles/{uid}`
- `ProfilePromptAnswer`
- `PhotoPromptAnswer`
- profile prompt catalog
- photo prompt catalog
- `updateUserProfile` patch schema

Tasks:

- [x] Inventory all current profile fields across Dart models, generated TS,
  Zod, rules, seed data, and live validation tooling.
- [x] Decide how to encode Firestore timestamps, nullable fields, server-only
  projection fields, and URL fields in schemas.
- [x] Create `contracts/README.md`.
- [x] Create embedded prompt answer schemas.
- [x] Create prompt catalog JSON files.
- [x] Create first full document schemas for `users` and `publicProfiles`.
- [x] Create `updateUserProfile` patch schema.
- [x] Add valid/invalid golden fixtures for prompts and profile patches.

Exit criteria:

- No runtime behavior has to change yet.
- The contract slice represents current intended schema truth.
- Known mismatches are explicitly listed as migration tasks.

### Phase 2: Generator Scaffolding

Status: complete.

Tasks:

- [x] Add Node tooling dependencies for schema validation/type generation.
- [x] Add Dart dev/tool dependency for schema validation.
- [x] Implement `tool/generate_schema_contracts.mjs`.
- [x] Generate TypeScript interfaces and Ajv validators.
- [x] Generate Dart constants for prompt catalogs, limits, and enum values.
- [x] Add a `--check` mode that fails when generated output is stale.
- [x] Add a schema compile test.
- [x] Add generated-output check to `tool/check_data_contract.sh`.

Exit criteria:

- A contract edit causes deterministic generated output changes.
- CI can fail if generated output is stale.

### Phase 3: Profile Validation Convergence

Status: complete.

Tasks:

- [x] Replace duplicated prompt length constants with generated constants.
- [x] Align Dart and Functions height bounds. Current evidence shows Dart
  accepts 120-220 cm while `updateUserProfile` accepts 90-260 cm.
- [x] Align optional email, Instagram, age preference, run preference, and
  prompt validation semantics.
- [x] Add golden validation vectors shared by Dart and TypeScript tests.
- [x] Migrate `updateUserProfile` from handwritten Zod to generated Ajv
  validation, or add a transitional test proving the Zod schema matches the
  generated JSON Schema.
- [x] Keep normalization logic explicit and tested: trimming, blank-line
  collapsing, empty prompt filtering, timestamp conversion.

Exit criteria:

- Dart and Functions agree on accepted and rejected profile payloads.
- Changing a profile constraint in the contract updates both surfaces or fails
  tests.

### Phase 4: Seeder Contract Enforcement

Status: complete for seed document shape and catalog enforcement; projection
equality moves to Phase 5.

Tasks:

- [x] Make seed profile builders consume generated prompt catalog constants.
- [x] Remove new-write `bio` from seed data.
- [x] Build synthetic `profilePrompts` and `photoPrompts` through generated
  prompt catalog helpers.
- [x] Validate every planned `users` and `publicProfiles` document before
  writing.
- [x] Split schema failures from stale-reference failures in seed output.
- [x] Add tests that seed plans reject unknown fields, legacy fields, invalid
  prompt ids, and overlong prompts.
- [x] Add projection-equivalence tests for mismatched public profile data in
  Phase 5 once the pure projection helper exists.
- [x] Add a dry-run schema gate to `tool/check_data_contract.sh`.

Exit criteria:

- Seed dry runs cannot silently create schema-drifted profile documents.
- Demo ops cannot warm accounts with stale prompt/profile shapes if future
  demo-profile writes use the shared seed validator.

### Phase 5: Projection And Backfill Repair

Status: projection helper, parity, dry-run repair tooling, and live environment
repair execution complete.

Tasks:

- [x] Extract/test a pure `users -> publicProfiles` projection helper in
  Functions.
- [x] Reuse or mirror that projection helper in seeding.
- [x] Add validation that compares seeded public profiles to canonical user
  projections where appropriate.
- [x] Write dry-run-first repair tooling for legacy `bio` and stale profile
  prompt data in dev/staging/prod.
- [x] Design and scope a future `ProfilePhoto` storage migration for grouped
  photo URL, thumbnail URL, prompt, storage-path, and moderation metadata. This
  should be dual-read/backfill-first because upload, thumbnail, moderation,
  deletion, and avatar code all currently use the parallel arrays.
- [x] Run repair in dev first, then staging/prod only with explicit apply and
  environment safeguards.

Exit criteria:

- Public profile projection drift is detectable.
- Legacy bio/profile prompt migration is repeatable and documented.

### Phase 6: Firestore Rules And Ownership Metadata

Status: profile field ownership, user rules allow-list drift checks, focused
emulator coverage for tightened profile fields, and schema-derived rules
semantic drift checks for current direct-write surfaces are complete. A full
Firestore Rules compiler remains intentionally out of scope.

Tasks:

- [x] Generate a machine-readable field ownership projection from schemas.
- [x] Compare generated ownership projection with
  `tool/firestore_contract.json`.
- [x] Add checks for rules field allowlists against schema field sets.
- [x] Add rules emulator tests for any newly tightened profile fields.
- [x] Add schema-derived semantic checks for rules-owned direct writes.
- [x] Document any fields intentionally tolerated for legacy reads.

Exit criteria:

- Rules drift is caught by contract checks and emulator tests before deploy.

### Phase 7: Expand Beyond Profiles

Status: run-domain, social/payment/safety, moderation flag, lightweight
operational document, callable payload, and direct client-write operation
slices complete. Future storage-object metadata contracts are tracked under the
`ProfilePhoto` migration.

Candidate next collections:

- [x] run clubs,
- [x] run club memberships,
- [x] runs,
- [x] run participations,
- [x] saved runs,
- [x] payments,
- [x] matches and messages,
- [x] notifications,
- [x] reviews,
- [x] blocks/reports/safety documents.

Remaining secondary candidates:

- [x] run club host claims,
- [x] schedule locks,
- [x] deleted-user tombstones,
- [x] seed run manifests,
- [x] config, onboarding draft, rate-limit, and function-receipt operational
  documents,
- [x] callable payload schemas for run, run club, review, safety, payment, and
  Places operations,
- [x] moderation flag documents,
- [x] storage-object metadata contracts to introduce with the future
  `ProfilePhoto` migration,
- [x] direct client-write operation schemas for contextual profile decisions,
  chat messages, saved-run edges, notification read updates, and match unread
  resets.

Ordering rule:

- Prefer high-churn or high-risk documents first.
- Prefer documents touched by demo seeding and Functions callables before
  passive read-only surfaces.

### Phase 8: Callable Payload Contracts

Status: complete for callable request validation and direct client-write
operation schemas.

Tasks:

- [x] Add generated schemas for profile update payloads.
- [x] Add generated schemas for run-club lifecycle and membership callables.
- [x] Add generated schemas for run lifecycle and participant action
  callables.
- [x] Add generated schemas for review callables.
- [x] Add generated schemas for safety callables.
- [x] Add generated schemas for payment callables.
- [x] Add generated schemas for Places callables.
- [x] Remove remaining handwritten Zod callable validators.
- [x] Remove the Functions `zod` dependency.

Related follow-up:

- [x] Direct client writes now have generated operation schemas where the
  write surface is stable enough to contract: contextual profile decisions,
  chat message create, saved-run create/delete, notification read update, and
  match unread reset.

Exit criteria:

- Callable request validation uses generated Ajv validators.
- Trimming/normalization remains explicit and tested at the callable boundary.
- A callable payload contract edit changes generated types/validators or fails
  stale-output checks.

### Phase 9: Storage/API Rename Playbook

Status: observe guard, count-validation tooling, dual-read/dual-write app
support, and historical parity verification are complete; primary-path trigger
cutover remains pending explicit production release work.

Candidate: rename logical `swipes` to contextual profile decisions/catches once
the product language has fully moved away from swiping.

Tasks:

- [x] Add logical contract metadata while keeping storage path unchanged.
- [x] Introduce generated path constants and ban new raw path strings outside
  the generated registry and migration tooling.
- [x] Decide final storage name: `profileDecisions`.
- [x] Create migration plan using observe, dual-read, dual-write, backfill,
  new-primary, freeze-old, retire-old phases.
- [x] Add migration tests and count validation before any production apply.
- [x] Implement dual-read/dual-write while keeping `swipes` as the trigger
  source of truth.
- [x] Add dry-run-first tooling to backfill historical `swipes` into
  `profileDecisions`.
- [x] Verify historical `swipes` -> `profileDecisions` parity in dev, staging,
  and prod with `tool/validate_profile_decision_migration.mjs --require-parity`
  after a dry-run backfill found no writes needed.
- [ ] Cut over the trigger path only after a release containing dual-write
  clients is deployed, platform Remote Config `min_build_*` gates are raised to
  the compatible build, and a final parity check passes.

Exit criteria:

- The rename can proceed without app code manually hunting raw collection
  strings or silently losing old decisions.

Full schema-contract gate result on 2026-05-15:

```bash
./tool/check_data_contract.sh
```

Result: passed after public-profile live repair, `ProfilePhoto` contract
scaffolding, profile-decision dual-read/dual-write, and profile-decision
backfill/parity tooling were all in place.

## Risk Register

| Risk | Mitigation |
| --- | --- |
| JSON Schema cannot directly model all Firestore runtime values. | Use explicit `x-firestore-type` metadata and adapters. |
| Full document and patch semantics get conflated. | Keep separate full-document and operation-specific patch schemas. |
| Firestore rules are over-generated and become unreadable. | Start with metadata checks and generated constants, not a full rules compiler. |
| Freezed model generation fights contract generation. | Keep Freezed as the app model layer initially; generate constants/validators first. |
| Generated schema types and Admin SDK facade types diverge. | Keep JSON Schema canonical and document `functions/src/shared/firestore.ts` as a transitional runtime facade until a schema-driven Admin SDK generator replaces it. |
| Seed validation slows down demo operations. | Compile validators once and validate planned docs before network writes. |
| Live production data has legacy shape. | Use dry-run-first repair scripts and environment gates before tightening rules. |
| Contract files become another stale source of truth. | CI must fail stale generated output and schema fixture drift. |

## First Migration Slice Recommendation

Start with profiles and prompts because that is where recent product work has
created the most immediate drift:

1. Move prompt catalogs into shared contract JSON.
2. Generate Dart prompt catalog helpers from the shared JSON.
3. Generate TypeScript prompt id/limit constants and Ajv embedded validators.
4. Add profile prompt/photo prompt golden fixtures.
5. Make `updateUserProfile` validate against generated Ajv or parity-test Zod.
6. Make seed data emit and validate `profilePrompts`/`photoPrompts`, never
   legacy `bio`.
7. Add repair/backfill tooling for existing legacy prompt data.

This gives us a valuable end-to-end slice without taking on every Firestore
collection or a risky storage rename at once.

## Decision Log

| Date | Decision |
| --- | --- |
| 2026-05-15 | Use contract-first JSON Schema governance rather than Dart-only, Zod-only, or seeder-local schemas. |
| 2026-05-15 | Keep TypeScript Cloud Functions for production because Dart Functions support is experimental and does not deploy Firestore triggers yet. |
| 2026-05-15 | Prefer Ajv for Node/runtime contract validation; remove Zod from Functions once callables are contract-generated. |
| 2026-05-15 | Keep `functions/src/shared/firestore.ts` only as a transitional Admin SDK typing facade; do not use it as canonical schema truth. |
| 2026-05-15 | Start migration with profiles/prompts/seeding before broader Firestore collection coverage. |

## Resume Notes

When resuming this migration:

1. Run `git status --short` and preserve unrelated dirty work.
2. Read this file, then the current relevant sections of:
   - `docs/firestore_functions_data_contract_tracker.md`
   - `docs/demo_data_seeding.md`
   - `docs/backend_operation_catalog.md`
3. Inspect current profile drift with:
   - `lib/user_profile/domain/user_profile.dart`
   - `lib/public_profile/domain/public_profile.dart`
   - `lib/user_profile/domain/profile_validation.dart`
   - `lib/user_profile/domain/profile_prompts.dart`
   - `functions/src/profiles/updateUserProfile.ts`
   - `functions/src/profiles/syncPublicProfile.ts`
   - `tool/seed_demo_data.mjs`
   - `tool/firestore_contract.json`
4. Begin Phase 1 unless a newer tracker update says otherwise.
