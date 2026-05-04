# Email Draft: Converting RunDraft to Freezed

## Why we're making this change

`RunDraft` was the only domain model in the app using manual `fromJson`/`toJson`
serialization — every other model (`AppUser`, `RunClub`, `Payment`, `Run`,
`Match`, `Swipe`, `Review`, `PublicProfile`, `ChatMessage`, `OnboardingDraft`)
already used Freezed with `json_serializable`.

The manual serialization was 55 lines of boilerplate (`fromJson`, `toJson`,
`listFromJson`, `listToJson`) that Freezed generates for free, plus it was
missing `==`, `hashCode`, and `copyWith` — all of which Freezed generates
automatically.

## What changed

### Before (146 lines)

```dart
import 'dart:convert';

class RunDraft {
  const RunDraft({
    required this.id,
    required this.runClubId,
    required this.savedAt,
    this.distance,
    // ... 19 fields total
  });

  final String id;
  final String runClubId;
  final DateTime savedAt;
  // ... 16 more field declarations

  factory RunDraft.fromJson(Map<String, dynamic> json) => RunDraft(
    id: json['id'] as String,
    // ... 19 lines of manual field casting
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    // ... 19 lines of manual JSON encoding
  };

  static List<RunDraft> listFromJson(String jsonString) { ... }
  static String listToJson(List<RunDraft> drafts) { ... }
}
```

### After (70 lines)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'run_draft.freezed.dart';
part 'run_draft.g.dart';

@freezed
abstract class RunDraft with _$RunDraft {
  const factory RunDraft({
    required String id,
    required String runClubId,
    required DateTime savedAt,
    // ... fields declared once in the factory constructor
    @Default(60) int durationMinutes,
  }) = _RunDraft;

  factory RunDraft.fromJson(Map<String, dynamic> json) =>
      _$RunDraftFromJson(json);
}

extension RunDraftX on RunDraft {
  bool get isEmpty => ...;  // 14 null checks — unchanged
  String get summary => ...; // unchanged
}
```

The `listFromJson`/`listToJson` helpers moved to the repository file (3 lines
each) since they were specific to the SharedPreferences storage format.

## Key decisions

1. **`@Default(60) int durationMinutes`** — This field had a default value of
   60 in the old constructor. The `@Default` annotation tells Freezed to use
   this default when the field is omitted from JSON.

2. **`DateTime` serialization** — `json_serializable` handles `DateTime`
   natively via `DateTime.parse()` ↔ `toIso8601String()`, which matches the
   old manual behavior exactly.

3. **`isEmpty` and `summary` in extension** — These are domain logic, not
   serialization. They stay in a `RunDraftX` extension, following the same
   pattern used by `RunClubX` and other Freezed models in the codebase.

4. **`listFromJson`/`listToJson` moved to repository** — These were simple
   `jsonDecode` + `map(fromJson)` / `map(toJson)` + `jsonEncode` wrappers (3
   lines each). Moving them to the repository keeps the domain model focused
   on data, not storage format.

## How to verify

```bash
dart analyze lib/runs/domain/run_draft.dart lib/runs/data/run_draft_repository.dart
```

No issues. The existing draft tests exercise serialization and eviction.
