---
doc_id: contract_type_safety_followups
status: active
started: 2026-05-25
parent_tracker: contract_type_safety_tracker.md
owner: contracts
---

# Contract Type-Safety Follow-Ups (Delegatable Backlog)

Self-contained todos derived from the contract type-safety sweep on
`codex/contract-type-safety-cleanup`. Each item is sized to hand off to a
teammate (or a Codex agent) cold: title, why it matters, exact files,
success criteria, and effort estimate. Pick any one in isolation; only the
explicitly-listed dependencies matter.

Effort key: **S** = under half a day, **M** = 1–2 days, **L** = 3–5 days,
**XL** = multi-week / multi-deploy.

---

## A. Direct continuations (high leverage, low risk)

### A1. Migrate inline-edit bottom sheets to typed `UpdateUserProfilePatch`

**Why.** `ProfileEditController.saveFields(Map<String, dynamic> fields)`
currently wraps each call in `UpdateUserProfilePatch.raw(fields)` so the
boundary stays typed. The ~6 inline-edit widgets in
`lib/user_profile/presentation/widgets/profile_inline_editors.dart` still
hand-roll `{'fieldName': value}` maps, which is where typos can sneak in.

**What.**
1. Change `ProfileEditController.saveFields` signature to
   `Future<void> saveFields(UpdateUserProfilePatch patch)`.
2. Update each inline editor (`_HeightEditorState`,
   `_ProfileInlineSingleChoiceEntryEditorState`,
   `_ProfileInlineDualSliderEditorState`, etc.) to construct a typed patch
   instead of a map. Each editor knows the single field it owns.
3. Remove the `UpdateUserProfilePatch.raw` call in the controller.

**Success criteria.**
- `grep -r "UpdateUserProfilePatch.raw" lib/` returns nothing under
  `lib/user_profile/presentation/`.
- `flutter test test/profile/profile_widgets_test.dart` passes.
- `./tool/check_data_contract.sh` green.

**Files.** `lib/user_profile/presentation/widgets/profile_inline_editors.dart`,
`lib/user_profile/presentation/profile_edit_controller.dart`,
`test/profile/profile_widgets_test.dart`.

**Effort.** M.

---

### A2. Swap Functions Ajv validators to the new dedicated payload schemas

**Why.** This sweep added `event_booking_payload.schema.json` and
`create_razorpay_order_payload.schema.json` and the Dart client sends
through those typed DTOs. The matching Functions handlers still validate
against `EventIdCallablePayload`. Same shape, but the validator name and
the typed payload diverge — confusing for future readers.

**What.** In `functions/src/payments/createRazorpayOrder.ts` and
`functions/src/events/signUpForFreeEvent.ts`:
1. Replace `validateEventIdCallablePayload` import with
   `validateCreateRazorpayOrderCallablePayload` /
   `validateEventBookingCallablePayload`.
2. Replace the `EventIdCallablePayload` TS type with the dedicated payload
   type.
3. Update unit tests in `createRazorpayOrder.test.ts` and
   `signUpForFreeEvent.test.ts` if they assert specific validator names.

**Success criteria.**
- `grep -l validateEventIdCallablePayload functions/src/payments/createRazorpayOrder.ts functions/src/events/signUpForFreeEvent.ts` returns nothing.
- `npm --prefix functions test` green.
- `./tool/check_data_contract.sh` green.

**Files.** 2 Functions handler files + their `.test.ts` siblings.

**Effort.** S.

---

### A3. Clean up the lingering stack trace in profile widget tests

**Why.** Running `flutter test test/profile/profile_widgets_test.dart`
prints a stack trace from `_InlineSaveState.saveFields` in the
`profile_inline_editors.dart` save flow. The test passes (the error is
caught), but it clutters CI output and obscures real failures.

**What.** Reproduce the test, find the `then((_)` block in
`_InlineSaveState.saveFields` that triggers the caught exception, and
either:
1. Make the test stop provoking it (preferred), or
2. Annotate the catch with a clear comment explaining why it's expected.

**Success criteria.** `flutter test test/profile/profile_widgets_test.dart`
shows no stack traces.

**Files.** `lib/user_profile/presentation/widgets/profile_inline_editors.dart`,
`test/profile/profile_widgets_test.dart`.

**Effort.** S.

---

## B. Generator extensions (CONTRACT-DART-GEN-001 follow-ups)

### B1. Generate `UpdateUserProfilePatch` from schema

**Why.** Today the typed `UpdateUserProfilePatch` is hand-written
(44 fields) and a schema-parity test guards drift. The generator could
emit it directly from `contracts/patches/update_user_profile.schema.json`,
making the parity test redundant and making "add a schema field → patch
class auto-extends" the new normal.

**What.** Extend `tool/contracts/generate_schema_contracts.mjs`:
1. Detect the patch shape (`properties.fields.properties` under a top-level
   `properties.fields`).
2. Emit a `<Name>Patch` Dart class with every field as a nullable named
   parameter. Use a sentinel for nullable-vs-omitted disambiguation
   (mirror the existing hand-written pattern).
3. Handle the four type families the patch needs:
   - **Enums** — emit Dart enum types (`Gender`, `RelationshipGoal`, etc.)
     and `.name` in `toJson`. Resolve through `$ref` to
     `shared/profile_common.schema.json`.
   - **DateTime** — when the schema field is `type: integer` with the
     "milliseconds since epoch" description (e.g. `dateOfBirth`), accept
     `DateTime?` in the constructor and emit `.millisecondsSinceEpoch` in
     `toJson`.
   - **Lists of typed objects** — `List<ProfilePromptAnswer>?` → call
     `.toJson()` per item.
   - **Object refs** (`profilePhotos` items) — re-use existing imported
     types.
4. Remove `UpdateUserProfileCallablePayload` from `DART_CALLABLE_REQUEST_SKIP`.
5. Delete `lib/user_profile/domain/update_user_profile_patch.dart` and
   re-export the generated class from the same path for back-compat.
6. Migrate or delete `test/core/update_user_profile_patch_test.dart` (the
   parity-by-construction goal is now structural).

**Success criteria.**
- `grep -rn "UpdateUserProfilePatch" lib/` shows the class lives only in
  `lib/core/schema_contracts/generated/`.
- Adding a new field to
  `contracts/patches/update_user_profile.schema.json`,
  regenerating, and re-running the gate succeeds without touching
  hand-written code.
- All 8 caller sites compile unchanged.
- `flutter test test/core/` + `test/user_profile/` green.

**Files.** `tool/contracts/generate_schema_contracts.mjs`,
`lib/user_profile/domain/update_user_profile_patch.dart` (delete),
`lib/core/schema_contracts/generated/callable_request_dtos.g.dart`
(generated), `test/core/update_user_profile_patch_test.dart` (rework).

**Effort.** L.

---

### B2. Generate `UpdateClubPatch` (after B1)

**Why.** Same generator improvement; `UpdateClubPatch` has 13 fields and
nested `ClubHostDefaults`. Once B1 lands the patch-shape detector, this
is a one-line spec addition + the same deletion.

**What.** Add the spec entry, delete
`lib/clubs/domain/update_club_patch.dart`, re-export from the generated
path, drop or rework `test/core/update_club_patch_test.dart`.

**Success criteria.** Same as B1 (substitute "club" for "user profile").

**Files.** `lib/clubs/domain/update_club_patch.dart` (delete),
`tool/contracts/generate_schema_contracts.mjs`, test files.

**Effort.** S (depends on B1).

---

### B3. Generate `CreateEventCallableRequest`, `UpdateEventCallableRequest`, `CreateClubCallableRequest`

**Why.** These are still hand-written because they carry
`fromEvent(Event)` / `fromDomain(...)` domain-adapter factories that walk
the domain model and convert DateTime → millis. They also have nested
typed objects (`EventDetailsCallableDto`, `EventConstraintsCallableDto`,
`EventMeetingLocation`) that the generator currently flattens to
`Map<String, Object?>`.

**What.**
1. After B1 lands the typed nested-class emit, generate the request
   classes for these payloads.
2. Move the adapter factories (`fromEvent`, `fromDomain`, `fromReview`)
   to dedicated `lib/<feature>/data/<feature>_callable_adapters.dart`
   files as top-level functions:
   ```dart
   CreateEventCallableRequest createEventCallableRequestFromEvent(
     Event event, {String? inviteCode, Map<String, Object?>? eventSuccessDefaults},
   ) => CreateEventCallableRequest(...);
   ```
3. Migrate callers — `lib/events/data/event_repository.dart`,
   `lib/reviews/data/reviews_repository.dart`, etc.
4. Delete the hand-written request classes from
   `lib/events/data/event_callable_dtos.dart` and friends; keep response
   decoders + adapters.

**Success criteria.**
- `test/core/callable_dto_contracts_test.dart` and all repository tests
  green.
- Adding a field to `contracts/callables/create_event_payload.schema.json`
  auto-extends the generated request class.
- Adapter functions remain feature-local and well-named.

**Files.** `tool/contracts/generate_schema_contracts.mjs`,
`lib/events/data/event_callable_dtos.dart`,
`lib/clubs/data/club_callable_dtos.dart`,
`lib/reviews/data/review_callable_dtos.dart`, and new
`*_callable_adapters.dart` files per feature.

**Effort.** L. Depends on B1.

---

### B4. Update CONTRACT-DART-GEN-001 backlog entry

**Why.** The entry says "partially_complete" but predates this sweep's A1
work. Anyone reading the backlog should see the actual status: 31
callable classes generated, 3 patch classes are next, etc.

**What.** Rewrite `docs/audit_registry/backlog.json` entry
`CONTRACT-DART-GEN-001` to capture what shipped (typed patches + parity
tests) and link to follow-ups B1–B3.

**Success criteria.** `jq empty docs/audit_registry/backlog.json` passes;
entry reflects the latest state.

**Files.** `docs/audit_registry/backlog.json`.

**Effort.** S.

---

## C. Schema migrations awaiting product / scheduling decision

### C1. Retire legacy profile photo arrays

**Why.** `photoUrls`, `photoThumbnailUrls`, `photoPrompts` are parallel
arrays superseded by the typed `profilePhotos` object array. Migration
is fully staged (`contracts/migrations/profile_photos_storage.json`
shows dev + prod applied 2026-05-16). The `retire_legacy_arrays` phase
is gated on minimum supported app version — older clients still need
the arrays to render.

**What.**
1. Verify the app-version floor is past the cutoff where all live
   clients read `profilePhotos`. Check Crashlytics / Firebase Remote
   Config for active version distribution.
2. Drop array fields from `contracts/firestore/users.schema.json` and
   `contracts/firestore/public_profiles.schema.json`.
3. Remove the array fields from `UpdateUserProfilePatch` and the
   freezed `UserProfile` / `PublicProfile` domain classes.
4. Drop the projection writes in `functions/src/profiles/syncPublicProfile.ts`
   and `functions/src/profiles/updateUserProfile.ts`.
5. Run `tool/data/strip_public_profile_coordinates.mjs`-style cleanup
   that removes the legacy fields from existing documents in dev → staging
   → prod.
6. Update `contracts/migrations/profile_photos_storage.json` phase to
   `retire_legacy_arrays: complete`.

**Success criteria.**
- `grep photoUrls contracts/firestore/{users,public_profiles}.schema.json`
  returns nothing.
- Live `users/` documents in prod no longer carry these fields
  (validated by `tool/data/validate_firestore_data.mjs`).
- All UI surfaces still render profile photos.

**Effort.** M. **Blocker.** product confirmation on the app-version floor.

---

### C2. Execute swipes → profileDecisions storage rename

**Why.** Tools and contracts exist
(`tool/data/validate_profile_decision_migration.mjs`,
`contracts/migrations/swipes_to_profile_decisions.json`,
`tool/data/backfill_profile_decisions.mjs`). The actual rename hasn't
started. Every day deferred, more code accretes against the stale
`swipes/` naming.

**What.** Follow the seven phases in the migration JSON:
observe → dual-read-ready → dual-write → backfill → new-primary →
freeze-old → retire-old. Each phase has its own gate. The Functions
side and Dart side need to advance together at each step.

**Success criteria.**
- `swipes/{uid}/outgoing/{targetId}` no longer the source of truth.
- All Dart, Functions, and Firestore rules reference `profileDecisions`.
- `tool/data/validate_profile_decision_migration.mjs` reports zero drift
  across all environments.
- No regression in matching behavior measured against the pre-migration
  baseline.

**Effort.** XL (multi-week, multi-deploy). **Blocker.** product
scheduling.

---

### C3. Migrate run-specific profile fields to activity-generic shape

**Why.** `paceMinSecsPerKm`, `paceMaxSecsPerKm`, `preferredDistances`,
`runningReasons`, `preferredRunTimes`, `runPreferencesVersion` live
directly on `users/{uid}` despite the product now spanning many activity
kinds (pickleball, padel, tennis, yoga, dinner, mixers…). The shape
locks the profile to running.

**What.**
1. Product decision: nest under a `runningPreferences` sub-object, OR
   introduce per-activity preference objects, OR keep the running fields
   as the universal "movement preferences" and add a separate generic
   layer.
2. Add the new shape to `contracts/firestore/users.schema.json` and the
   patch.
3. Backfill: copy legacy fields → new shape in
   `tool/data/backfill_*.mjs`. Keep legacy fields readable for one
   client-version cycle.
4. Migrate the freezed `UserProfile` model + `UpdateUserProfilePatch`.
5. Update all UI surfaces: filters, profile detail, onboarding pace step,
   match cards.

**Success criteria.**
- New shape live, legacy fields read-only-for-back-compat.
- All UI surfaces work for non-running activities without showing pace
  fields.

**Effort.** L. **Blocker.** product design decision on shape.

---

## D. Architectural epics (defer with rationale)

### D1. Generate Dart freezed domain classes from schema (`CONTRACT-DART-GEN-002`)

**Why.** 32 freezed domain classes hand-mirror their JSON Schemas. The
new `domain_fixture_parity_test.dart` catches some drift but the classes
themselves remain parallel sources. Schemas added a field today won't
cause a Dart compile error.

**What.** Build a Dart class generator that emits json_serializable
annotations, `@TimestampConverter()`, Dart enum types, and equality
semantics. Each schema in `contracts/firestore/` → one Dart file.
Hand-written classes get deleted; derived getters
(`Event.distanceMiles`, `Club.isOwnedBy`, etc.) move to extension
methods on the generated classes.

**Success criteria.**
- All 32 domain classes generated from `contracts/firestore/`.
- No hand-written `*.dart` for domain classes (only `_$Foo` parts).
- Extension files hold the derived getters.
- `domain_fixture_parity_test.dart` becomes structurally redundant.

**Effort.** XL (multi-day epic). **Note.** Highest-value but biggest scope;
revisit when team has bandwidth.

---

### D2. Retire `firestore.ts` Admin SDK Timestamp overlay

**Why.** Documented as parallel-by-design (Admin SDK uses live
`FirebaseFirestore.Timestamp`, schema-generated TS uses serialized
`{_seconds, _nanoseconds}`). The long-term cleanup is to emit
Timestamp-typed variants from the schema generator and delete the
Dart-derived overlay.

**What.**
1. Extend `tool/contracts/generate_schema_contracts.mjs` to emit a
   second TS variant per schema where `x-firestore-type: timestamp`
   fields are typed as `FirebaseFirestore.Timestamp`. Output to a
   `firestore_admin_types/` subfolder.
2. Migrate all 38 Functions imports from `../shared/firestore` to the
   new generated path (`grep -rl "from.*shared/firestore['\"]" functions/src`).
3. Delete `functions/src/shared/firestore.ts`,
   `tool/contracts/firestore_ts_overlay.json`,
   `tool/contracts/generate_firestore_types.dart`.
4. Remove the corresponding gate steps from `tool/check_data_contract.sh`.

**Success criteria.**
- `functions/src/shared/firestore.ts` and the overlay JSON deleted.
- All Functions code compiles + tests pass.
- Schema-derived generator is the sole source of TS types.

**Effort.** L. **Note.** Blocked on schema generator extension;
high-effort cleanup with bounded marginal value.

---

## E. Test + tooling polish

### E1. Add Storage upload conformance tests

**Why.** `contracts/storage/*.schema.json` declares
`x-storage-content-type-pattern` and `x-storage-max-bytes` for each
upload path, but no test verifies that client upload helpers enforce
these limits before kicking off the upload. The Storage emulator
rejects bad uploads server-side, but the client UX is better if it
rejects them client-side first.

**What.** For each upload helper in
`lib/image_uploads/data/image_upload_repository.dart`
(`uploadClubCover`, `uploadClubProfileImage`,
`uploadProfilePhoto`, `uploadChatImage`):
1. Add a negative test: oversize file → rejected before upload starts.
2. Add a negative test: non-image content type → rejected.
3. Tests should read the limit from the storage schema rather than
   hard-coding it, so they fail when the schema changes.

**Success criteria.** New tests in `test/image_uploads/` (folder
doesn't exist yet) cover each of the 5 storage paths with both
positive and negative cases.

**Effort.** M.

---

### E2. Add a typed Suvbot repository test

**Why.** `suvbot_repository.requestAction` now uses
`RequestSuvbotDemoOperationCallableRequest` internally, but
`chat_screen_test.dart` uses a `FakeSuvbotRepository` that captures
`actionId` directly. The wire format is not validated end-to-end.

**What.** Create `test/chats/suvbot_repository_test.dart` covering:
1. `fetchActions()` decodes a sample
   `ListSuvbotDemoActionsCallableResponse` payload correctly.
2. `requestAction()` sends a payload that matches the
   `RequestSuvbotDemoOperationCallablePayload` schema.

Use the existing `TestHttpsCallable` helper pattern (see
`test/clubs/clubs_repository_test.dart`).

**Success criteria.** New test file with both cases passing.

**Effort.** S.

---

### E3. Add Dart class parity tests for the embedded types currently only validated via fixture round-trip

**Why.** `domain_fixture_parity_test.dart` covers documents, but the
embedded types (`EventConstraints`, `EventFormatSnapshot`,
`EventPolicyBundle`, `ClubHostProfile`, `ProfilePhoto`,
`ProfilePromptAnswer`, `PhotoPromptAnswer`) only get indirect
coverage through their parent documents. A direct
fixture-decode test for each embedded type catches drift faster.

**What.** Extend `domain_fixture_parity_test.dart` with cases for
each embedded type, loading from
`contracts/fixtures/valid/<embedded>_<x>.json` where available, or
inline-built fixtures otherwise.

**Success criteria.** Every embedded type from
`contracts/embedded/` and the `event_common.schema.json#/definitions`
section is exercised by a `Class.fromJson(fixture)` test.

**Effort.** S.

---

## F. Hygiene / housekeeping

### F1. Resolve the stash on the original branch

**Why.** When the audit branch was cut, ~210 pre-existing modifications
were sitting in the working tree. They're preserved in
`stash@{0}` (`pre-audit-cleanup: docs update + WIP create_event_screen edits`)
and the original `codex/event-success-live-permission-fix` branch.

**What.** Review what's in the stash and decide per item:
- Restore on the original branch and continue.
- Cherry-pick into the audit branch (if related).
- Discard (if stale).

**Success criteria.** `git stash list` is either empty (handled) or each
remaining entry is annotated with status.

**Effort.** S.

---

### F2. Document the new contract surface in `contracts/README.md`

**Why.** This sweep added `contracts/storage/`,
`x-callable-aliases`, `x-catch-ownership`, two new patch payload schemas,
two new response schemas, and several new generator concepts (DTO
skip-list, embedded-type `propertyPath` resolver). `contracts/README.md`
hasn't been updated to describe these new surfaces.

**What.** Update `contracts/README.md`:
- Add `contracts/storage/` to the Current Slice list.
- Document `x-callable-aliases` (purpose + verification).
- Document `x-catch-ownership` (already mentioned in `data_contracts.md`,
  but the contract README should cross-reference).
- Mention the typed patch classes (`UpdateUserProfilePatch`,
  `UpdateClubPatch`) and how parity is enforced.

**Success criteria.** A new contributor reading `contracts/README.md`
understands every directory under `contracts/` and every `x-*` extension
in use.

**Files.** `contracts/README.md`.

**Effort.** S.

---

## Suggested ordering

If items are picked up sequentially:

1. **A2** (S) — clean alignment, zero risk
2. **A3** (S) — clean test output
3. **B4** + **F2** (S each) — keep docs honest
4. **E2** + **E3** (S) — round out test coverage
5. **A1** (M) — finish the patch migration
6. **E1** (M) — storage conformance
7. **B1** → **B2** → **B3** (L → S → L) — generator extension epic
8. **C1** (M, when product clears app-floor)
9. **C3** → **C2** (L → XL) — schema/path migrations
10. **D2** (L) → **D1** (XL) — architectural epics

If items go to different people in parallel: B1/B2/B3 are a single
generator extension and should land together; A1/A2/A3/E2/E3 can each
go to a different person.
