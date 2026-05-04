# Email 9: CI/CD Pipeline + Offline-Aware UI

**To:** Suvrat
**Subject:** [Catch Audit #10, #9] GitHub Actions CI + connectivity banner

---

## What changed

Two changes, one infra and one UI:

1. **CI/CD pipeline** — New `.github/workflows/flutter-ci.yml` runs `flutter analyze` and `flutter test --concurrency=1` on every PR and push to main.

2. **Offline connectivity banner** — `AppShell` now shows a subtle banner ("You're offline. Content may not be up to date.") when the device loses connectivity.

---

## Why

**CI/CD:** The only existing GitHub Action tested Firestore rules. No automated Dart analysis or test runner existed. A broken build could be merged and discovered only during manual release — painful to fix under time pressure. Adding analysis + tests to CI costs 30 lines of YAML and catches regressions before they reach the branch.

**Offline UI:** Firestore SDK caches data locally by default on mobile, so the app partially works offline. But there was no visual indicator — users couldn't tell if they were viewing stale cached data or live data. The connectivity banner removes this ambiguity without blocking interaction.

---

## How

### CI/CD: 25-line workflow

```yaml
name: Flutter CI

on:
  pull_request:
  push:
    branches: [main]

jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.41.x"
          channel: stable
      - run: flutter pub get
      - name: Static analysis
        run: flutter analyze
      - name: Unit & widget tests
        run: flutter test --concurrency=1
```

**Design decisions:**
- `--concurrency=1` — required by the TableView isolation issue documented in `TESTS.md`. Running tests in parallel causes flaky failures.
- `timeout-minutes: 15` — generous ceiling. A typical `flutter analyze` + test run takes 3-5 minutes on GitHub's Ubuntu runners. 15 minutes prevents hung tests from consuming billable minutes.
- `flutter-version: "3.41.x"` — pinned to the major.minor currently in use. The `x` patch wildcard picks up patch releases (bug fixes) but not minor releases (potential breaking changes).
- `branches: [main]` — the workflow also runs on push to main (post-merge verification). PR checks alone don't catch issues introduced by merge resolution.

### Offline UI: connectivity_plus listener

Added `connectivity_plus` (standard Flutter package, zero native config) and wired a stream listener in `AppShell`:

```dart
class _AppShellState extends ConsumerState<AppShell> {
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((results) {
      if (!mounted) return;
      final offline = results.isEmpty ||
          results.every((r) => r == ConnectivityResult.none);
      if (offline != _isOffline) {
        setState(() => _isOffline = offline);
      }
    });
  }
```

The banner renders as a `MaterialBanner` at the top of the `Scaffold` body, above the navigation shell:

```dart
Scaffold(
  body: Column(
    children: [
      if (_isOffline) _ConnectivityBanner(),
      Expanded(child: widget.navigationShell),
    ],
  ),
  ...
)
```

The banner is non-blocking — the user can still navigate, scroll, and interact with cached data. It's purely informational.

**Design decision — `setState` rather than Riverpod provider:**
The connectivity state is local to `AppShell` (only one banner in the app). Creating a Riverpod provider for a single consumer would add unnecessary indirection. If multiple widgets need connectivity state later (e.g., to disable "Send" buttons when offline), extracting to a provider is a 5-minute refactor.

**Design decision — `MaterialBanner` rather than `SnackBar`:**
`MaterialBanner` is persistent (stays until connectivity returns) and non-interactive (doesn't require a dismiss action). A `SnackBar` would auto-dismiss after a few seconds, which is wrong for a persistent state like offline. `MaterialBanner` is the Material Design component specifically designed for persistent, non-critical status messages.

---

## Files changed

```
 .github/workflows/flutter-ci.yml         | +25 lines (new)
 lib/core/presentation/app_shell.dart     | +26 lines
 pubspec.yaml                             | +1 dep (connectivity_plus)
```
