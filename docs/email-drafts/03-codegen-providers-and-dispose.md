From: Claude Code <noreply@anthropic.com>
To: suvratgarg@gmail.com
Subject: [Fixes 2 & 3] Converted manual providers to codegen + disposed onboarding state

---

## Fix 2: Converted 4 manual providers to @riverpod codegen

### What I changed

**3 files modified:**

1. **`lib/matches/data/match_repository.dart`** — `matchStreamProvider` was a manual `StreamProvider.autoDispose.family`. Converted to:
```dart
@riverpod
Stream<Match?> matchStream(Ref ref, String matchId) =>
    ref.watch(matchRepositoryProvider).watchMatch(matchId: matchId);
```

2. **`lib/safety/data/safety_repository.dart`** — Both providers were manual. Converted to:
```dart
@Riverpod(keepAlive: true)
SafetyRepository safetyRepository(Ref ref) => SafetyRepository(
  ref.watch(firebaseFirestoreProvider),
  ref.watch(firebaseFunctionsProvider),
  ref.watch(firebaseAuthProvider),
);

@riverpod
Stream<List<BlockedUser>> blockedUsers(Ref ref) {
  final uid = ref.watch(uidProvider).asData?.value;
  if (uid == null) return const Stream.empty();
  return ref.watch(safetyRepositoryProvider).watchBlockedUsers(uid: uid);
}
```

3. **`lib/analytics/app_analytics.dart`** — `appAnalyticsProvider` was a manual `Provider<AppAnalytics>`. Converted to:
```dart
@riverpod
AppAnalytics appAnalytics(Ref ref) => AppAnalytics();
```

Also ran `dart run build_runner build --delete-conflicting-outputs` to generate the `.g.dart` files.

### Why this matters

The codebase had **4 manual providers** alongside **66 codegen providers**. This inconsistency meant:

1. **Different override APIs**: Manual providers use `provider.overrideWith(...)`, codegen providers use `provider.overrideWith((ref) => ...)`. Mixing both is confusing.

2. **Different naming conventions**: Codegen providers consistently use the `Provider` suffix (e.g., `firebaseFirestoreProvider`). Mixing manual and codegen risks naming collisions.

3. **Generated helpers**: Codegen provides `overrideWithValue()`, debug hashes, and proper family support automatically. Manual providers miss these.

### The @riverpod naming convention

When you write:
```dart
@riverpod
Stream<Match?> matchStream(Ref ref, String matchId) => ...;
```

Riverpod generates:
- A provider named `matchStreamProvider`
- If the function takes parameters (like `String matchId`), it becomes a `.family` provider
- If the return type is `Stream<T>`, it becomes a `StreamProvider`
- If the return type is `Future<T>`, it becomes a `FutureProvider`
- If no `keepAlive: true`, it auto-disposes

The function name determines the provider name:
- `matchStream` → `matchStreamProvider`
- `blockedUsers` → `blockedUsersProvider`
- `safetyRepository` → `safetyRepositoryProvider`
- `appAnalytics` → `appAnalyticsProvider`

This is why the old manual providers' call sites didn't need changes — the generated names match.

### When you might need a manual provider

Manual providers are occasionally needed for:
- Complex provider types not supported by codegen
- Providers with unusual lifecycle requirements
- Third-party integration patterns

In this codebase, none of the 4 manual providers had special requirements — they were all straightforward patterns that codegen handles perfectly.

---

## Fix 3: OnboardingController disposed after completion

### What I changed

**File:** `lib/onboarding/presentation/onboarding_controller.dart`, in the `complete()` method.

Added at the end of the method:
```dart
// Onboarding is complete — the router will redirect away shortly.
// Invalidate self so the keepAlive provider is disposed and its
// state (including OnboardingData) is freed.
ref.invalidateSelf();
```

### Why this matters

`OnboardingController` is a `@Riverpod(keepAlive: true)` notifier. This means its state (`OnboardingData` with phone number, name, DOB, gender, photos, etc.) stays in memory for the **entire app session** — even after the user completes onboarding and never returns to it.

Before this fix:
- App launches → user completes onboarding → OnboardingController stays alive forever
- Memory held: ~2-5KB of user PII that's no longer needed

After this fix:
- App launches → user completes onboarding → `ref.invalidateSelf()` disposes the provider
- Next time someone watches `onboardingControllerProvider`, a fresh instance is created with default state

### Pattern: self-invalidating keepAlive providers

This is a useful Riverpod pattern for providers that are:
1. **keepAlive** (because they hold multi-step state that must survive navigation)
2. **Finite lifecycle** (they have a natural "done" point)

```dart
Future<void> completeTask() async {
  await doWork();
  ref.invalidateSelf();  // Clean up after ourselves
}
```

The router will already have redirected away (because `profileComplete: true` triggered the GoRouter redirect), so the invalidation is invisible to the user.
