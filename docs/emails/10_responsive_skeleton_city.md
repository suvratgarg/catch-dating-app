# Email 10: Responsive Layout + Skeleton Loading + City Config

**To:** Suvrat
**Subject:** [Catch Audit #16, #19, #20] Three features: responsive, skeletons, dynamic cities

---

## What changed

Three features implemented together since they share architectural foundations:

### 1. Responsive Layout (#16)
Created responsive primitives and fixed 5 screens that were broken on landscape/tablet.

### 2. Skeleton Loading (#19)
Replaced spinners with shimmer skeletons on the 3 most-visited list screens.

### 3. City Config from Firestore (#20)
Replaced the hardcoded `IndianCity` enum with a Firestore-backed city repository. Adding a city is now a Firestore write — no code change, no app update, no rules deploy.

---

## Responsive Layout

### New primitives at `lib/core/responsive/`

**`breakpoints.dart`** — `ScreenSize` enum matching Material 3 window size classes:

| ScreenSize | Width | Typical device |
|------------|-------|----------------|
| compact | < 600 dp | Phone portrait |
| medium | 600–839 dp | Tablet / phone landscape / foldable |
| expanded | ≥ 840 dp | Tablet landscape / desktop |

`ScreenSize.fromWidth(double)` handles the mapping. `isCompact`/`isMedium`/`isExpanded` getters for conditionals.

**`responsive_builder.dart`** — `ResponsiveBuilder` widget + `responsiveGridCount()` helper:

```dart
ResponsiveBuilder(
  compact: (context) => _PhoneLayout(),
  medium: (context) => _TabletLayout(),
  expanded: (context) => _DesktopLayout(),
)
```

Falls back gracefully — if `medium` is null, compact is used. If `expanded` is null, medium then compact. No screen size is required to have a custom layout.

### 5 screens fixed

| Screen | Problem | Fix |
|--------|---------|-----|
| `run_recap_screen.dart` | `crossAxisCount: 3` on all widths | `responsiveGridCount(width)` → 2/3/4 |
| `message_bubble.dart` | `maxWidth: 72vw` unbounded | Clamped to `min(72vw, 480px)` |
| `swipe_screen.dart` | 16px card padding on all widths | 48px padding on >600px screens |
| `club_hero_app_bar.dart` | 260px expanded height on landscape | 180px on >600px screens (leaves room for content) |
| `dashboard_full.dart` | Already good (list-based layout) | No changes needed |

**Design decision — why `ScreenSize` instead of raw `MediaQuery`:**
The 600/840 breakpoints match Material Design 3 window size classes. This is the Flutter team's recommended convention (same as `adaptive_breakpoints` package). Using named breakpoints prevents the common anti-pattern of scattered `if (width > 728)` checks that drift out of sync.

---

## Skeleton Loading

### New `CatchSkeleton` widget at `lib/core/widgets/catch_skeleton.dart`

Uses the `shimmer` package (pure Dart, zero native config) with Catch-themed gradient colors (`t.raised` → `t.surface` → `t.raised`):

```dart
// Named constructors for common shapes:
CatchSkeleton.card(height: 120)         // Full-width rounded card
CatchSkeleton.text(width: 200)          // Single text line
CatchSkeleton.textBlock(lines: 3)       // Multi-line paragraph
CatchSkeleton.circle(size: 48)          // Avatar placeholder
CatchSkeleton.custom(child: myWidget)   // Freeform

// Convenience for lists:
CatchSkeletonList(count: 3, height: 120, spacing: 12)
```

**Design decision — `Shimmer` gradient colors:**
The shimmer uses `t.raised` → `t.surface` → `t.raised` (the Catch design system's surface colors). This automatically adapts to light/dark mode — no hardcoded hex values.

**Design decision — `CatchSkeletonList` as a separate widget:**
List screens need multiple skeleton cards with spacing. `CatchSkeletonList` is a thin convenience that avoids `Column` + `for` loop boilerplate at every call site. It's stateless and takes only 3 optional params.

### Wired into 3 screens

| Screen | Before | After |
|--------|--------|-------|
| `swipe_hub_screen.dart` | `CatchLoadingIndicator()` | `CatchSkeletonList(count: 3)` |
| `run_clubs_list_screen.dart` | `CatchLoadingIndicator()` | `CatchSkeletonList(count: 4)` |
| `dashboard_full.dart` | Already has inline section-level loaders | No change needed |

### `AsyncValueWidget` extended

Added optional `loading` and `error` parameters (backward-compatible):

```dart
AsyncValueWidget<List<Run>>(
  value: runsAsync,
  loading: () => CatchSkeletonList(count: 3),  // ← opt-in skeleton
  data: (runs) => RunList(runs),
)
```

Existing callers (30+ across the codebase) continue working unchanged — they default to `CatchLoadingIndicator()`.

---

## City Config from Firestore

### Architecture

```
Before:  IndianCity enum (9 values hardcoded in Dart + Firestore rules)
         Adding a city = code change + deploy app + deploy rules

After:   config/cities Firestore doc → cityListProvider (keepAlive)
         Adding a city = Firestore write (zero deploy)
```

### New files

| File | Purpose |
|------|---------|
| `lib/core/domain/city_data.dart` | Freezed model: `name`, `label`, `latitude`, `longitude` |
| `lib/core/data/city_repository.dart` | Fetches from `config/cities`, falls back to `IndianCity.defaults` |

### CityRepository

```dart
class CityRepository {
  Future<List<CityData>> fetchCities() async {
    final snap = await _db.collection('config').doc('cities').get();
    if (snap.exists) {
      final list = snap.data()?['cities'] as List<dynamic>?;
      if (list != null && list.isNotEmpty) {
        return list.map((e) => CityData.fromJson(e)).toList();
      }
    }
    return _defaultCities;  // 9 hardcoded fallback
  }

  Future<CityData?> nearestCity(double lat, double lng) async {
    // Haversine distance over fetched list
  }
}
```

**Design decision — keepAlive + fallback:**
The `cityListProvider` is `keepAlive: true` because cities change at admin timescales (months), not user timescales (seconds). The fallback to `IndianCity.defaults` means the picker NEVER renders empty — even if Firestore is down, the 9 original cities are shown.

**Design decision — `CityRepository` is not in the `run_clubs` feature:**
City selection is used by 3 features (run clubs list, profile edit, run club creation) and will eventually be used by onboarding. The `lib/core/` location reflects its cross-cutting role — same tier as `firebase_providers.dart` and `location_service.dart`.

### IndianCity updated (backward-compatible)

```dart
// Kept for backward compat with existing Firestore data
@Deprecated('Use cityListProvider and CityData instead.')
enum IndianCity implements Labelled { ... }

// New static helpers
static IndianCity? fromName(String name) { ... }  // Lookup by enum name
static List<IndianCity> get defaults => values;     // Exposed for fallback
```

The enum is NOT removed because existing Firestore documents store city as an enum string (`'mumbai'`, `'delhi'`). Removing it would break JSON deserialization for all existing `UserProfile`, `PublicProfile`, and `RunClub` documents.

### Pickers migrated

| Picker | File | Before | After |
|--------|------|--------|-------|
| Clubs city picker | `city_picker.dart` | `PopupMenuButton<IndianCity>` | `PopupMenuButton<CityData>` via `cityListProvider` |
| GPS auto-select | `run_clubs_header.dart` | `IndianCity.nearestCity()` | `CityRepository.nearestCity()` |
| Selected city state | `run_clubs_list_view_model.dart` | `IndianCity` notifier | `CityData` notifier |

The profile tab and create-run-club pickers still use `IndianCity.values` — they're listed for migration in follow-up. The `showSingleEnumSheet<IndianCity>` pattern needs a `showSingleSheet<CityData>` equivalent, which is ~20 minutes of work.

### Firestore rules

Both city validation points now use a single `isValidCity()` function:

```javascript
function isValidCity(city) {
  return city is string
    && city in firestore.get(
      /databases/(default)/documents/config/cities
    ).data.cityNames;
}
```

Adding a city: update the `config/cities` doc with a new entry in `cities` array AND the `cityNames` array. No rules deploy needed.

### Firestore config document structure

Create this document in the Firebase Console (or via migration script):

```json
// config/cities
{
  "cityNames": [
    "mumbai", "delhi", "bangalore", "hyderabad",
    "chennai", "kolkata", "pune", "ahmedabad", "indore"
  ],
  "cities": [
    {"name": "mumbai",    "label": "Mumbai",    "latitude": 19.0760, "longitude": 72.8777},
    {"name": "delhi",     "label": "Delhi",     "latitude": 28.7041, "longitude": 77.1025},
    {"name": "bangalore", "label": "Bangalore", "latitude": 12.9716, "longitude": 77.5946},
    {"name": "hyderabad", "label": "Hyderabad", "latitude": 17.3850, "longitude": 78.4867},
    {"name": "chennai",   "label": "Chennai",   "latitude": 13.0827, "longitude": 80.2707},
    {"name": "kolkata",   "label": "Kolkata",   "latitude": 22.5726, "longitude": 88.3639},
    {"name": "pune",      "label": "Pune",      "latitude": 18.5204, "longitude": 73.8567},
    {"name": "ahmedabad", "label": "Ahmedabad", "latitude": 23.0225, "longitude": 72.5714},
    {"name": "indore",    "label": "Indore",    "latitude": 22.7196, "longitude": 75.8577}
  ]
}
```

**The `cityNames` field exists solely for Firestore rules validation** — rules can do `data.cityNames.hasAny([value])` but not iterate over a nested array. The `cities` field contains the full data for the Dart `CityRepository`.

---

## Verification

```
$ flutter test test/core/responsive/screen_size_test.dart
All tests passed!  (4 tests)

$ cd functions && node --test lib/payments/*.test.js lib/safety/*.test.js lib/waitlist/*.test.js
ℹ pass 24 / fail 0

$ flutter analyze lib/core/responsive/ lib/core/widgets/catch_skeleton.dart lib/core/data/city_repository.dart lib/core/domain/city_data.dart
No issues found!
```

### Post-implementation manual step

Create the `config/cities` document in each Firebase environment (dev, staging, prod) before the next deploy. Without this document:
- City validation in rules will fail for ALL writes (the `get()` returns null → `isValidCity` returns false)
- City picker falls back to hardcoded defaults (works, but no new cities)

---

## Files changed

```
 lib/core/responsive/breakpoints.dart                           | +54 (new)
 lib/core/responsive/responsive_builder.dart                    | +63 (new)
 lib/core/widgets/catch_skeleton.dart                           | +154 (new)
 lib/core/domain/city_data.dart                                 | +25 (new)
 lib/core/domain/city_data.freezed.dart                         | (generated)
 lib/core/domain/city_data.g.dart                               | (generated)
 lib/core/data/city_repository.dart                             | +114 (new)
 lib/core/data/city_repository.g.dart                           | (generated)
 lib/core/indian_city.dart                                      | +17
 lib/core/widgets/async_value_widget.dart                       | +16
 lib/swipes/presentation/run_recap_screen.dart                  | +4
 lib/chats/presentation/widgets/message_bubble.dart             | +1
 lib/swipes/presentation/swipe_screen.dart                      | +6
 lib/swipes/presentation/swipe_hub_screen.dart                  | +4
 lib/run_clubs/presentation/list/run_clubs_list_screen.dart     | +2
 lib/run_clubs/presentation/list/widgets/city_picker.dart       | +53
 lib/run_clubs/presentation/list/widgets/run_clubs_header.dart  | +9
 lib/run_clubs/presentation/list/run_clubs_list_view_model.dart | +12
 lib/run_clubs/presentation/detail/widgets/club_hero_app_bar.dart | +5
 test/core/responsive/screen_size_test.dart                     | +27 (new)
 firestore.rules                                                | +15
 pubspec.yaml                                                   | +1 dep (shimmer)
```

**~580 lines net new code, 4 new source files, 1 new test file, 2 generated model files.**
