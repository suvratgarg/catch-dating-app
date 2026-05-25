---
doc_id: contract_type_safety_tracker
status: active
started: 2026-05-25
branch: codex/contract-type-safety-cleanup
owner: contracts
---

# Contract / Domain / Repository Type-Safety Tracker

Persistent execution checklist for the type-safety audit started 2026-05-25.
Source audit findings: see the previous review summary. Items are ordered by
priority and grouped by phase. Each item:

- Marks status as `todo` / `in_progress` / `done` / `deferred`
- Lists representative files
- Carries a short scope note

Update this file as items land (or are deferred with rationale). Do not re-add
prose explanation that lives in code or the JSON Schemas — keep this terse.

## Status legend

- ☐ `todo` — not yet started
- ◐ `in_progress` — being worked on now
- ☑ `done` — landed and verified
- ⊘ `deferred` — explicitly skipped, with rationale below

## Phase 1 — Quick wins (typed DTOs already exist, just wire them in)

### ☑ A2. Migrate `event_success_repository.dart` raw maps to typed DTOs
Four callables build raw `Map` literals despite generated DTOs existing.
- `overrideEventSuccessRotations` → `OverrideEventSuccessRotationsCallableRequest`
- `submitEventSuccessWingmanRequest` → `SubmitEventSuccessWingmanRequestCallableRequest`
- `startEventSuccessFirstHelloMission` → `StartEventSuccessFirstHelloMissionCallableRequest`
- `completeEventSuccessFirstHelloMission` → `CompleteEventSuccessFirstHelloMissionCallableRequest`

Files: `lib/event_success/data/event_success_repository.dart`

### ☑ A7. Remove `leaveWaitlist`'s dead `userId` parameter
`lib/events/data/event_repository.dart:378-390` — `userId` is never used in the
body. Either remove it or wire it through.

### ☑ A8. Exclude `UpdateUserProfileCallableRequest` from generated DTO file
Hand-written one in `user_profile_callable_dtos.dart` is canonical; the generated
copy is dead. Add a skip-list to the generator OR migrate (the latter blocks on
A1).

## Phase 2 — Add missing schemas and typed response wrappers

### ☑ A3. Typed response for `fetchEventSuccessWingmanCandidates`
Add `contracts/callable_responses/fetch_event_success_wingman_candidates_response.schema.json`
+ `FetchEventSuccessWingmanCandidatesCallableResponse` class.

Files: `lib/event_success/data/event_success_repository.dart` (line 723), test.

### ☑ A4. Suvbot callable contracts
`listSuvbotDemoActions` and `requestSuvbotDemoOperation` have no schemas. Either
add them to `contracts/callables/` + `contracts/callable_responses/`, or carve
out a `contracts/demo/` and document the carve-out.

Files: `lib/chats/data/suvbot_repository.dart`

### ☑ A5. Payment payload schemas
`EventBookingCallableRequest` and `CreateRazorpayOrderCallableRequest` have no
schema. Add `event_booking_payload.schema.json` and `create_razorpay_order_payload.schema.json`.
The hand-written DTOs do `inviteCode?.trim()` — keep that normalization (wrapper
delegates to generated `toJson()` after trimming).

Files: `contracts/callables/`, `lib/payments/data/payment_callable_dtos.dart`,
`test/core/callable_dto_contracts_test.dart`.

### ☑ A6. Survey callables without payload schemas
Quick audit: `signUpForFreeEvent`, `generateEventSuccessPods`,
`generateEventSuccessRotations`, `withdrawEventSuccessWingmanRequest`,
`fetchEventSuccessWingmanCandidates`. Most reuse `event_id_payload.schema.json`
informally. Add an `aliasOf` mechanism OR dedicated schemas.

## Phase 3 — Embedded-type organization and field-parity

### ☑ C1. Extract `EventMeetingLocation` and `EventFormatSnapshot` to own files
(`EventFormatSnapshot` already lived in `lib/activity/domain/activity_taxonomy.dart`.
This pass extracted `EventMeetingLocation` to its own file with a re-export
from `event.dart` for back-compat.)
Currently nested inside `lib/events/domain/event.dart`. Move to
`lib/events/domain/event_meeting_location.dart` and
`lib/events/domain/event_format_snapshot.dart`.

### ⊘ B2. Cross-check Dart embedded types against schema property paths
Deferred in favor of D2 (Dart round-trip tests). A JS-side check would need to
parse Dart source with a regex, which is brittle as freezed syntax evolves.
The Dart-side fromJson/toJson round-trip test in D2 catches the same drift
class with higher fidelity: if the Dart class is missing a schema field,
`fromJson(fixture)` drops it and `toJson()` doesn't restore it — the round-trip
test fails. Revisit if D2 turns out to leave a gap.

## Phase 4 — Round-trip and decode-boundary tests

### ☑ D2. Domain class ↔ fixture round-trip tests
12 cases in `test/core/domain_fixture_parity_test.dart`. Helper `_loadFixture`
converts `{_seconds, _nanoseconds}` to `Timestamp` instances before
`fromJson`, injects doc-id fields where the Firestore converter would, and
asserts the Dart class decodes without throwing.
For each freezed domain class with a corresponding `contracts/fixtures/valid/`
fixture, add a test that `Class.fromJson(fixture).toJson()` round-trips back to
the fixture (modulo Timestamp normalization).

### ☑ D1b. Negative tests for response parsers
New "response parsers throw on malformed input" test in
`callable_dto_contracts_test.dart`. Covers `CreateClub`, `MarkEventAttendance`,
`StartClubHostConversation`, `PlaceDetails`,
`FetchEventSuccessWingmanCandidates`, `ListSuvbotDemoActions`, `SuvbotActionItem`,
`RazorpayOrder` (typed exception), and documents the intentional
permissive behavior of `PlacesAutocompleteCallableResponse`.
Each `*CallableResponse.fromCallableData(...)` should throw when required
fields are missing. Add explicit tests.

### ☐ D4. Storage rules schema-conformance test
The `contracts/storage/*.schema.json` files declare `x-storage-content-type-pattern`
and `x-storage-max-bytes`. Add a test that the upload helpers enforce those
limits before kicking off the upload.

## Phase 5 — Biggest lever: typed UpdateUserProfilePatch

### ☑ A1. Typed `UpdateUserProfilePatch` + `UpdateClubPatch`
Hand-written + schema-parity-tested in this pass (the schema → Dart class
generator that's pending in CONTRACT-DART-GEN-001 didn't ship; the hand-
written + test-enforced approach matched the same single-source-of-truth
goal in much less code). 44 fields wired up for users (including all enum
types and Timestamp → millis conversion), 13 for clubs. Repository method
signatures swapped from `Map<String, dynamic> fields` to typed patches; all
8 caller sites migrated (filters, settings, onboarding ×2, profile_edit,
4 fake repositories). `UpdateUserProfilePatch.raw()` / `UpdateClubPatch.raw()`
escape hatches let dynamic-field callers (inline editors, raw form data)
go through the same boundary. Schema parity tests in
`test/core/update_user_profile_patch_test.dart` and
`test/core/update_club_patch_test.dart` fail loudly when a schema field is
missing from the patch class (or vice versa).
Today every caller of `updateUserProfile` hand-rolls a `Map<String, dynamic>`.
Schema at `contracts/patches/update_user_profile.schema.json` defines the exact
valid field set under `properties.fields.properties`. Extend the Dart class
generator to emit nested typed classes for patch shapes; replace the
`UpdateUserProfileCallableRequest` wrapper and every caller.

Callers to migrate (8 known sites):
- `lib/swipes/presentation/filters_controller.dart:27`
- `lib/safety/presentation/settings_controller.dart:44` (incl. the dynamic
  `{preference.fieldName: value}` pattern)
- `lib/onboarding/presentation/onboarding_controller.dart:324, 348`
- `lib/user_profile/presentation/profile_edit_controller.dart:44`
- `lib/user_profile/data/user_profile_repository.dart:98, 110, 129, 135`

Also applies to `updateClub` in `lib/clubs/data/clubs_repository.dart:168` —
extend the same pattern.

## Phase 6 — Defer (escalate before scheduling)

### ⊘ B1. Generate Dart freezed domain classes from schema
Multi-day epic. Generator would need to emit json_serializable annotations,
Timestamp converters, enum types, and equality. Track separately under
`CONTRACT-DART-GEN-002` if approved.

### ⊘ E1. Retire legacy profile photo arrays (`photoUrls`/`photoThumbnailUrls`/`photoPrompts`)
Gated on minimum supported app version. See
`contracts/migrations/profile_photos_storage.json` phase `retire_legacy_arrays`.
Schedule when the app-version floor allows it.

### ⊘ E2. Rename `swipes` → `profileDecisions`
Tools and contract design exist (`tool/data/validate_profile_decision_migration.mjs`,
`contracts/migrations/swipes_to_profile_decisions.json`). Path rename is staged
but not executed. Needs product-level scheduling.

### ⊘ E5. Migrate run-specific profile fields to activity-generic shape
`paceMinSecsPerKm`, `paceMaxSecsPerKm`, `preferredDistances`, `runningReasons`,
`preferredRunTimes`, `runPreferencesVersion` are running-specific but live on a
profile that now covers many activity kinds. Significant product/contract debt.

### ⊘ E4. Eventually retire `firestore.ts` Admin SDK overlay
Generator could emit Timestamp-flavored variants directly. Out of scope until
the schema-derived generator handles Admin SDK Timestamps natively.

## Working notes / new findings

(Appended as work progresses.)
