# Firestore Type Synchronization — Auto-Generated TypeScript Interfaces

**Date:** 2026-05-05
**Context:** Eliminating manual Dart ↔ TypeScript type drift that caused production errors when model fields or enum values fell out of sync.
**Status:** Implemented and enforced in CI.

---

## The problem this solves

The app has **10+ Dart freezed models** (in `lib/*/domain/`) that define the Firestore document schema. Cloud Functions have **matching TypeScript interfaces** (in `functions/src/shared/firestore.ts`) that describe the same documents.

Before this change, the two were kept in sync **entirely by hand**. A developer would add a field to a Dart model like `UserProfile`, forget to update the TS interface, and one of two things would happen:

| Direction | What happens | Caught when? |
|-----------|-------------|--------------|
| **Dart field added, TS not updated** | Cloud Function reads the document but TS type doesn't know about the new field. No compile error. If the function needs that field, it silently reads `undefined`. | Runtime — bug or crash in production |
| **Dart field removed, TS still has it** | TS code compiles fine, but at runtime the field is always `undefined`. Functions that depend on it break. | Runtime — bug or crash in production |
| **Dart enum value added, TS not updated** | Cloud Function receives the new enum value but the TS union type doesn't include it. TypeScript narrows to `never` or rejects it. | Compile time if used in a switch, runtime otherwise |
| **Dart enum value removed, TS still has it** | TS code assumes the value exists. It never arrives. Logic branches become dead code. | Runtime — silently wrong behavior |

The `tsc` compiler only catches one narrow case: when TS code references a field that doesn't exist on the interface. It is **completely silent** when:

- Dart adds a new field → TS interface is missing it → functions see `undefined`
- Dart renames a field → TS interface has the old name → functions use the wrong key
- Dart adds/removes/reorders enum values → TS union type is stale

This caused **recurring production errors on a near-daily basis** as models evolved.

## The solution

A **Dart → TypeScript code generator** that reads the Dart freezed models and writes `functions/src/shared/firestore.ts` automatically. A **CI enforcement step** blocks any PR where the committed TS file doesn't match what the generator produces.

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Dart freezed models                          │
│  lib/user_profile/domain/user_profile.dart                      │
│  lib/runs/domain/run.dart                                       │
│  lib/matches/domain/match.dart                                  │
│  ... (10 models total)                                          │
│  lib/core/indian_city.dart (enum-only)                          │
└────────────────────┬────────────────────────────────────────────┘
                     │  reads & parses
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│  tool/generate_firestore_types.dart                             │
│                                                                 │
│  For each Dart file:                                            │
│    • Parses enums → TS union types                              │
│    • Parses @freezed factory constructors → TS interfaces       │
│    • Maps Dart types to TS equivalents                          │
│    • Handles @JsonKey, @Default, @TimestampConverter, etc.      │
│                                                                 │
│  Merges tool/firestore_ts_overlay.json:                         │
│    • TS-only interfaces (BlockDoc, ReportDoc, ModerationFlagDoc)│
│    • TS-only fields (fcmToken, deleted, participantIds)         │
│    • Field overrides (languages in PublicProfile)               │
└────────────────────┬────────────────────────────────────────────┘
                     │  writes
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│  functions/src/shared/firestore.ts                              │
│                                                                 │
│  AUTO-GENERATED. Header warns: "DO NOT EDIT DIRECTLY."          │
│  • Exported enum type aliases (sorted alphabetically)           │
│  • Document interfaces with JSDoc (Dart source, collection path)│
│  • Server-only interfaces from overlay                          │
└─────────────────────────────────────────────────────────────────┘
```

### Type mapping table

| Dart | TypeScript |
|------|-----------|
| `String` | `string` |
| `int` | `number` |
| `double` | `number` |
| `bool` | `boolean` |
| `List<T>` | `T[]` |
| `Map<String, T>` | `Record<string, T>` |
| `DateTime` with `@TimestampConverter()` | `FirebaseFirestore.Timestamp` |
| `DateTime?` with `@NullableTimestampConverter()` | `FirebaseFirestore.Timestamp \| null` |
| Custom enum `Foo` | `Foo` (the generated TS type alias) |
| Nested freezed type `Bar` | `Bar` (the generated TS interface) |

### Field optionality rules

| Dart declaration | TS output | Reason |
|-----------------|-----------|--------|
| `required String name` | `name: string` | Always present in Firestore |
| `String? instagramHandle` | `instagramHandle?: string \| null` | May be absent or explicitly null |
| `@Default('') String email` | `email: string` | `@Default` guarantees a value is always written |
| `@Default([]) List<String> tags` | `tags: string[]` | Same — the default ensures the field exists |
| `@JsonKey(includeToJson: false) required String uid` | *excluded* | Document ID, not stored in document data |
| `@JsonKey(unknownEnumValue: null) IndianCity? city` | `city?: IndianCity \| null` | Nullable enum with unknown fallback |

### What the overlay handles

Not everything is derivable from Dart models. The overlay (`tool/firestore_ts_overlay.json`) captures:

- **TS-only interfaces**: `BlockDoc`, `ReportDoc`, `ModerationFlagDoc` — server-owned documents with no Dart model
- **TS-only fields**: `fcmToken`, `deleted`, `deletedAt` on `UserProfileDoc` (written by Cloud Functions, not by the client)
- **TS-only fields**: `participantIds` on `MatchDoc` (denormalized by `onSwipeCreated`)
- **Field overrides**: `languages` on `PublicProfileDoc` (kept optional because `syncPublicProfile` conditionally spreads it)

When a new server-only field or interface is needed, add it to the overlay — not to the generated output.

## Developer workflow

### Adding a field to a Dart model

```bash
# 1. Edit the Dart model (e.g., add a field to UserProfile)
# 2. Run the generator
dart tool/generate_firestore_types.dart

# 3. Check that tsc still compiles (it may flag function code
#    that needs to handle the new field)
cd functions && npm run build

# 4. Update any Cloud Function code that reads/writes this model
# 5. Commit the Dart model change AND the regenerated firestore.ts
git add lib/user_profile/domain/user_profile.dart \
        functions/src/shared/firestore.ts
```

### Removing a field from a Dart model

```bash
# 1. Remove the field from the Dart model
# 2. Run the generator
dart tool/generate_firestore_types.dart

# 3. tsc will FAIL if any Cloud Function still references
#    the removed field — this is GOOD, it forces you to
#    update the function code before deploying
cd functions && npm run build

# 4. Fix the function code, then commit everything together
```

### Adding a TS-only field (no Dart model)

Edit `tool/firestore_ts_overlay.json` — add the field under the appropriate interface in `extraFields`. Run the generator. The field will appear in the output and won't be overwritten by future generator runs.

### npm convenience script

```bash
cd functions && npm run generate:types
```

This is equivalent to `dart ../tool/generate_firestore_types.dart`.

## CI enforcement

The Flutter CI workflow (`.github/workflows/flutter-ci.yml`) has a step after tests:

```yaml
- name: Verify Firestore types are in sync
  run: |
    dart tool/generate_firestore_types.dart
    git diff --exit-code functions/src/shared/firestore.ts
```

This **fails the PR** if:
- You changed a Dart model but didn't run the generator
- You manually edited `firestore.ts` instead of using the generator
- You changed the overlay but didn't regenerate

The CI failure message is clear: the diff shows exactly what fields are missing or extra. Fix by running `dart tool/generate_firestore_types.dart` and committing the result.

## Backward compatibility

### What happens when you remove a Dart field

| Scenario | Result |
|----------|--------|
| **Cloud Function still references the removed field** | `tsc` fails at build time. You **cannot** deploy without fixing the function code. This is the key safety guarantee. |
| **No function references the removed field** | The field is removed from the TS interface. Existing Firestore documents still have the field as dead data. No breakage — both Dart `fromJson` and `requireDoc<T>()` ignore unknown keys. |
| **You want to clean up dead fields from Firestore** | Separate data migration. Write a one-off script or batch write. Not a type-sync concern. |

### What happens when existing documents lack a new required field

If you add a `required` field to a Dart model, the generated TS interface marks it as non-optional. A Cloud Function reading an old document (without the field) will get `undefined`. This is the same behavior as before the generator — the generator doesn't create this problem, it just makes the types honest about it.

Mitigations:
- Use `@Default(value)` for new fields whenever possible (the field is always written going forward, and old documents get the default on next write)
- For truly required new fields, write a data migration before deploying the function changes

## Dart models covered

| Dart model | TS interface | Firestore collection |
|-----------|-------------|---------------------|
| `UserProfile` | `UserProfileDoc` | `/users/{uid}` |
| `PublicProfile` | `PublicProfileDoc` | `/publicProfiles/{uid}` |
| `RunClub` | `RunClubDoc` | `/runClubs/{clubId}` |
| `Run` | `RunDoc` | `/runs/{runId}` |
| `RunConstraints` | `RunConstraints` | *(embedded in RunDoc)* |
| `Payment` | `PaymentDoc` | `/payments/{paymentId}` |
| `Swipe` | `SwipeDoc` | `/swipes/{userId}/outgoing/{targetId}` |
| `Match` | `MatchDoc` | `/matches/{matchId}` |
| `ChatMessage` | `ChatMessageDoc` | `/chats/{matchId}/messages/{messageId}` |
| `Review` | `ReviewDoc` | `/reviews/{reviewId}` |

Models that intentionally do NOT have TS interfaces:
- `OnboardingDraft` — client-only Firestore collection, never read/written by Cloud Functions
- `RunDraft` — stored in `SharedPreferences`, not Firestore
- `AppVersionConfig` — sourced from Firebase Remote Config, not Firestore

## Enums exported

All Dart enums from the covered models are exported as TS type aliases:

`ChildrenStatus`, `DietaryPreference`, `DrinkingHabit`, `EducationLevel`, `Gender`, `IndianCity`, `Language`, `MatchStatus`, `PaceLevel`, `PaymentStatus`, `PreferredDistance`, `RelationshipGoal`, `Religion`, `RunReason`, `SexualOrientation`, `SmokingHabit`, `SwipeDirection`, `WorkoutFrequency`

Client-only enums are excluded: `RunSignUpStatus`, `RunEligibility` (and its sealed-class variants).

## How the parser works

The generator uses **regex-based parsing** of the Dart source files. It does not use the Dart analyzer package — this keeps it dependency-free and fast.

### Enum parsing

```
enum Foo implements Labelled {
  value1('Label 1'),
  value2('Label 2');

  const Foo(this.label);
  final String label;
}
```

- Matches `enum Name` blocks
- Splits at `;` to separate member declarations from class body
- Strips `///` and `//` comment lines
- Extracts member names line-by-line (handles simple single-line enums like `{ active, blocked }` via comma-splitting)
- Excludes client-only enums via a hardcoded deny-list

### Factory constructor parsing

```
const factory UserProfile({
  @JsonKey(includeToJson: false) required String uid,
  required String name,
  @TimestampConverter() required DateTime dateOfBirth,
  @Default([]) List<String> photoUrls,
  String? instagramHandle,
}) = _UserProfile;
```

- Finds `const factory ClassName({` using regex
- Extracts the body using **brace counting** (not regex) to handle nested braces in `@Default({})`
- Processes each line, joining annotation-only lines with their field lines
- Strips leading annotations via a paren-counting function that handles nested parentheses like `@Default(RunConstraints())`
- Extracts: field name, Dart type, nullability (`?`), and annotations (`required`, `@Default`, `@TimestampConverter`, `@NullableTimestampConverter`, `@JsonKey`)

### Annotation stripping

The `_stripAnnotations` function uses parenthesis-depth counting rather than regex to handle annotations with nested constructor calls:

```dart
@Default(RunConstraints()) RunConstraints constraints,
```

This would break a naive regex because `RunConstraints()` contains `()` inside `@Default()`.

## When to update the overlay

The overlay should be updated when:

1. **A new server-only document is added** (e.g., a new collection written exclusively by Cloud Functions) — add a new entry to `extraInterfaces`
2. **A new field is added to a document by Cloud Functions** (not by the client) — add to `extraFields` for the relevant interface
3. **The TS type of a field needs to differ from the Dart-derived type** — add the field name to `fieldOverrides` and define it in `extraFields`

The overlay is intentionally small. If you find yourself adding many entries, consider whether:
- The field should be in the Dart model instead
- The server-only document should have a Dart model (even if the client never reads it directly)
- You're working around a parser limitation (file a bug instead)

## Files

| File | Role |
|------|------|
| `tool/generate_firestore_types.dart` | The generator — parses Dart, writes TS |
| `tool/firestore_ts_overlay.json` | TS-only additions and field overrides |
| `functions/src/shared/firestore.ts` | Generated output — do not edit directly |
| `.github/workflows/flutter-ci.yml` | CI enforcement — `git diff --exit-code` on the generated file |
| `functions/package.json` | `generate:types` npm script |
