# Email Draft: Dart 3 pattern matching for route extra extraction

## Why

`go_router.dart` had 6 locations using the `is` + `!` + `as` triple check:

```dart
state.extra is PublicProfile ? state.extra! as PublicProfile : null
```

This pattern has three operations on the same value:
1. `state.extra is PublicProfile` — type test
2. `state.extra!` — null assertion (unnecessary since `is` already proves non-null)
3. `state.extra as PublicProfile` — type cast (redundant after `is` check)

Dart 3's switch expression with pattern matching replaces all three with a
single destructuring pattern.

## What changed

All 6 instances converted from ternary + cast to switch expressions:

```dart
// Before (3 operations on state.extra)
initialProfile: state.extra is PublicProfile
    ? state.extra! as PublicProfile
    : null,

// After (single pattern match)
initialProfile: switch (state.extra) {
  final PublicProfile p => p,
  _ => null,
},
```

The Set<String> variant similarly simplified:

```dart
// Before
vibeIds: state.extra is Set<String>
    ? state.extra! as Set<String>
    : const {},

// After
vibeIds: switch (state.extra) {
  final Set<String> ids => ids,
  _ => const {},
},
```

## Why switch expressions here

The switch expression is exhaustive — the compiler enforces that all types are
handled. If someone adds a new `extra` type to a route, the analyzer will
flag the switch as non-exhaustive (unless there's a `_` wildcard). The `_`
wildcard is explicit about the "I don't expect other types" intent, whereas
the ternary's `: null` is implicit.
