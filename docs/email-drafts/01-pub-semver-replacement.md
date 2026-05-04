# Email Draft: Replacing custom semver parser with pub_semver

## Why we're making this change

`lib/force_update/domain/version.dart` had a hand-written semver parser: it split
version strings on `.`, parsed each segment as an int, and manually compared
three version components. That's ~15 lines of custom logic that handles the
happy path (e.g. `1.2.3`) but silently treats any malformed input as `0.0.0`.

`pub_semver` is the standard Dart package for semver — it's the same library
`pub` itself uses. It handles pre-release tags (`1.2.3-alpha.1`), build
metadata (`1.2.3+build456`), and stricter error handling, all in a single
`Version.parse()` call with proper comparison operators.

## What changed

**Before** (`version.dart`):
```dart
bool isUpdateRequired({required String current, required String minimum}) {
  final cur = _parse(current);
  final min = _parse(minimum);
  for (var i = 0; i < 3; i++) {
    if (cur[i] < min[i]) return true;
    if (cur[i] > min[i]) return false;
  }
  return false;
}

List<int> _parse(String version) {
  try {
    final parts = version.split('.');
    return List.generate(3, (i) => i < parts.length ? int.parse(parts[i]) : 0);
  } catch (_) {
    return [0, 0, 0];
  }
}
```

**After**:
```dart
import 'package:pub_semver/pub_semver.dart';

bool isUpdateRequired({required String current, required String minimum}) {
  final cur = _tryParse(current);
  final min = _tryParse(minimum);
  return cur < min;
}

Version _tryParse(String version) {
  try {
    return Version.parse(version);
  } on FormatException {
    return Version.none; // 0.0.0
  }
}
```

## Key decisions

1. **Safety net preserved.** The old code treated unparseable strings as `0.0.0`
   so a malformed Remote Config value never blocks users. We keep that behavior
   using `Version.none` (which is literally `0.0.0`).

2. **`isBuildUpdateRequired` left untouched.** That function compares integer
   build numbers, not semver — no library needed.

3. **Only `formatException` caught.** We catch specifically `FormatException`
   rather than a blanket `catch (_)`. This means programming errors (e.g.
   nulls) still surface instead of being silently swallowed.

## How to verify

```bash
dart analyze lib/force_update/domain/version.dart
```

The existing `force_update` provider tests will exercise this path since
`forceUpdateRequiredProvider` calls `isUpdateRequired()`.
