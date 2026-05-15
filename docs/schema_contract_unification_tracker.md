---
doc_id: schema_contract_unification
version: 0.2.0
updated: 2026-05-15
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
- Generated TypeScript interfaces in `functions/src/shared/firestore.ts`.
- Handwritten Zod schemas inside Cloud Functions.
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

- `tool/generate_firestore_types.dart` already generates
  `functions/src/shared/firestore.ts` from selected Dart models plus
  `tool/firestore_ts_overlay.json`.
- `tool/check_data_contract.sh` already checks generated Firestore TS types,
  generated business constants, Firestore contract metadata, validator syntax,
  Functions lint/tests, Firestore rules tests, and focused Flutter tests.
- `tool/firestore_contract.json` records collection ownership, allowed fields,
  operations, exported functions, and migration notes.
- `tool/business_rules.json` generates shared Dart and TypeScript constants.
- `lib/user_profile/domain/profile_validation.dart` owns app-side profile
  constraints today.
- `functions/src/profiles/updateUserProfile.ts` owns handwritten Zod patch
  validation today.
- `lib/user_profile/domain/profile_prompts.dart` owns the current profile/photo
  prompt catalog today.
- `tool/seed_demo_data.mjs` and `tool/demo_ops_core.mjs` own demo data and
  warm-account write plans.

Current gaps:

- Dart validation and Zod validation can disagree.
- Full document schemas and partial update schemas are not generated from one
  contract.
- Prompt catalogs are Dart-only even though Functions and seed tools need the
  same prompt ids and limits.
- Seed data can drift into legacy or invalid shapes unless each script manually
  remembers current fields.
- Firestore rules and schema metadata are related but independently edited.
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
- Keep Zod temporarily only as a migration bridge where replacing it would add
  too much churn in one pass.

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
  schemaTypes.ts
  schemaValidators.ts
  schemaRegistry.ts

lib/core/schema_contracts/generated/
  schema_contracts.dart
  profile_prompt_catalog.dart
  validation_limits.dart

tool/generated/
  schema_registry.mjs
  seed_validators.mjs
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
  for height constants, callable `sexualOrientation` removal, rules height
  bounds, and seed output free of new-write `bio`.

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

Status: pending. The no-dependency source checker exists, but generated Dart,
TypeScript, and Ajv outputs have not been implemented.

Tasks:

- [ ] Add Node tooling dependencies for schema validation/type generation.
- [ ] Add Dart dev/tool dependency for schema validation.
- [ ] Implement `tool/generate_schema_contracts.mjs`.
- [ ] Generate TypeScript interfaces and Ajv validators.
- [ ] Generate Dart constants for prompt catalogs, limits, and enum values.
- [ ] Add a `--check` mode that fails when generated output is stale.
- [ ] Add a schema compile test.
- [ ] Add generated-output check to `tool/check_data_contract.sh`.

Exit criteria:

- A contract edit causes deterministic generated output changes.
- CI can fail if generated output is stale.

### Phase 3: Profile Validation Convergence

Status: pending.

Tasks:

- [ ] Replace duplicated prompt length constants with generated constants.
- [x] Align Dart and Functions height bounds. Current evidence shows Dart
  accepts 120-220 cm while `updateUserProfile` accepts 90-260 cm.
- [ ] Align optional email, Instagram, age preference, run preference, and
  prompt validation semantics.
- [ ] Add golden validation vectors shared by Dart and TypeScript tests.
- [ ] Migrate `updateUserProfile` from handwritten Zod to generated Ajv
  validation, or add a transitional test proving the Zod schema matches the
  generated JSON Schema.
- [ ] Keep normalization logic explicit and tested: trimming, blank-line
  collapsing, empty prompt filtering, timestamp conversion.

Exit criteria:

- Dart and Functions agree on accepted and rejected profile payloads.
- Changing a profile constraint in the contract updates both surfaces or fails
  tests.

### Phase 4: Seeder Contract Enforcement

Status: pending.

Tasks:

- [ ] Make seed profile builders consume generated prompt catalog constants.
- [x] Remove new-write `bio` from seed data.
- [ ] Build synthetic `profilePrompts` and `photoPrompts` through generated
  helpers. Interim state reads from shared contract catalog JSON directly.
- [ ] Validate every planned `users` and `publicProfiles` document before
  writing.
- [ ] Split schema failures from stale-reference failures in seed output.
- [ ] Add tests that seed plans reject unknown fields, legacy fields, invalid
  prompt ids, overlong prompts, and mismatched projection data.
- [ ] Add a dry-run schema gate to `tool/check_data_contract.sh`.

Exit criteria:

- Seed dry runs cannot silently create schema-drifted profile documents.
- Demo ops cannot warm accounts with stale prompt/profile shapes.

### Phase 5: Projection And Backfill Repair

Status: pending.

Tasks:

- [ ] Extract/test a pure `users -> publicProfiles` projection helper in
  Functions.
- [ ] Reuse or mirror that projection helper in seeding.
- [ ] Add validation that compares stored public profiles to canonical user
  projections where appropriate.
- [ ] Write dry-run-first repair tooling for legacy `bio` and stale profile
  prompt data in dev/staging/prod.
- [ ] Design and scope a future `ProfilePhoto` storage migration for grouped
  photo URL, thumbnail URL, prompt, storage-path, and moderation metadata. This
  should be dual-read/backfill-first because upload, thumbnail, moderation,
  deletion, and avatar code all currently use the parallel arrays.
- [ ] Run repair in dev first, then staging/prod only with explicit apply and
  environment safeguards.

Exit criteria:

- Public profile projection drift is detectable.
- Legacy bio/profile prompt migration is repeatable and documented.

### Phase 6: Firestore Rules And Ownership Metadata

Status: pending.

Tasks:

- [ ] Generate a machine-readable field ownership projection from schemas.
- [ ] Compare generated ownership projection with
  `tool/firestore_contract.json`.
- [ ] Add checks for rules field allowlists against schema field sets.
- [ ] Add rules emulator tests for any newly tightened profile fields.
- [ ] Document any fields intentionally tolerated for legacy reads.

Exit criteria:

- Rules drift is caught by contract checks and emulator tests before deploy.

### Phase 7: Expand Beyond Profiles

Status: pending.

Candidate next collections:

- run clubs,
- runs,
- run participations,
- payments,
- matches and messages,
- notifications,
- reviews,
- saved runs,
- blocks/reports/safety documents.

Ordering rule:

- Prefer high-churn or high-risk documents first.
- Prefer documents touched by demo seeding and Functions callables before
  passive read-only surfaces.

### Phase 8: Storage/API Rename Playbook

Status: pending.

Candidate: rename logical `swipes` to contextual profile decisions/catches once
the product language has fully moved away from swiping.

Tasks:

- [ ] Add logical contract metadata while keeping storage path unchanged.
- [ ] Introduce generated path constants and ban new raw path strings outside
  the generated registry and migration tooling.
- [ ] Decide final storage name: candidate names include `profileDecisions`,
  `catchDecisions`, `profileReactions`, or `catches`.
- [ ] Create migration plan using observe, dual-read, dual-write, backfill,
  new-primary, freeze-old, retire-old phases.
- [ ] Add migration tests and count validation before any production apply.

Exit criteria:

- The rename can proceed without app code manually hunting raw collection
  strings or silently losing old decisions.

## Risk Register

| Risk | Mitigation |
| --- | --- |
| JSON Schema cannot directly model all Firestore runtime values. | Use explicit `x-firestore-type` metadata and adapters. |
| Full document and patch semantics get conflated. | Keep separate full-document and operation-specific patch schemas. |
| Firestore rules are over-generated and become unreadable. | Start with metadata checks and generated constants, not a full rules compiler. |
| Freezed model generation fights contract generation. | Keep Freezed as the app model layer initially; generate constants/validators first. |
| Zod and Ajv coexist too long. | Track each callable migration and require either generated Ajv usage or parity tests. |
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
| 2026-05-15 | Prefer Ajv for Node/runtime contract validation; keep Zod only as a transitional bridge or parity-checked wrapper. |
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
