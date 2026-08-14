# Catch Tests

Git owns the test-file inventory. Use `git ls-files '*test*'` when you need a
current list; this document owns only the durable commands and testing policy.

## Standard suites

```sh
flutter test
(cd apps/consumer && flutter test --concurrency=1)
(cd apps/host && flutter test --concurrency=1)
bash tool/test_app_shell_integration.sh
flutter test --concurrency=1 test/goldens
node tool/run.mjs check test:flutter-test-size
(cd widgetbook && flutter analyze --no-fatal-warnings --no-fatal-infos && flutter build web --release)
npm --prefix functions test
npm --prefix functions run test:rules
npm run web:typecheck
node tool/run.mjs check --category meta
```

Use focused tests while iterating, then run the owning surface's full gate before handoff. Never run multiple Flutter analyzer/test processes concurrently. Add regression coverage beside the owned surface and make recurring architectural rules enforceable through the tool manifest.

Functions tests are discovered recursively from compiled
`functions/lib/**/*.test.js` plus `functions/test/**/*.test.cjs`; rules specs
remain in the emulator-owned `test:rules` lane. Adding a new nested Functions
domain test therefore requires no script edit.

`.github/workflows/flutter-ci.yml` compiles Widgetbook on every relevant Flutter
change and publishes an LCOV plus feature-level Markdown coverage artifact.
`.github/workflows/visual-integration-ci.yml` runs desktop goldens with the
checked 0.30% macOS raster tolerance, deterministic headless app-shell wrappers,
and a bounded native macOS app-shell smoke sequentially for relevant changes,
on weekdays, and on manual dispatch; failed golden images are retained as CI
artifacts. Pass a device id and scope to the runner—for example,
`bash tool/test_app_shell_integration.sh macos smoke` or
`bash tool/test_app_shell_integration.sh macos all`—for an explicit native
pass. Live Firebase/device evidence remains a release-runbook lane rather than
being implied by repository integration tests.

## Coverage and test maintainability

Coverage is an evidence surface, not a global percentage gate:

```sh
flutter test --concurrency=1 --exclude-tags=golden --coverage
node tool/test/flutter_coverage_report.mjs \
  --lcov coverage/lcov.info \
  --format markdown \
  --output coverage/flutter-coverage-summary.md
```

The report separates handwritten code from generated/config code and groups
observed lines by top-level Flutter feature. LCOV does not include files the
test process never loads, so the report says "observed" rather than implying
repository-wide completeness. Use the feature rows to choose focused additions;
do not introduce an aggregate pass/fail threshold without reviewed product-risk
evidence.

New or split Flutter test specs stay at or below 1,200 lines. Existing oversized
specs are recorded exactly and cannot grow:

```sh
node tool/test/check_flutter_test_size.mjs --check
# Only after a reviewed split or reduction:
node tool/test/check_flutter_test_size.mjs --write-baseline
```

`test/dashboard/dashboard_screen_test.dart` is the reference decomposition: its
full-home-shell group lives in the same Dart test library through
`dashboard_full_home_shell_tests.dart`, preserving private fixtures while making
the focused spec independently navigable in failures.

Explore, Event Success, core primitives, Host operations, and Profile use the
same library-part pattern, organized by behavioral area. Their former five
oversized entrypoints are now below the ceiling; each behavior part is also
below the ceiling.

Expected-error tests and deterministic captures should inject
`ErrorLogger.silent(...)` or a recording `consoleSink`. Production defaults
still print and report unexpected failures; never make the global logger silent
to quiet a test.

## Catch UI enforcement

`flutter analyze` remains the generic Flutter/Dart analysis gate, but it does
not load the local Catch UI analyzer plugin in this workspace. A targeted
`dart analyze lib` also skips the plugin. Catch lint verification must run from
the repository root through the checked wrappers:

```sh
bash tool/check_catch_ui_lints.sh
bash tool/check_catch_ui_lint_drift.sh --check
node tool/design/check_component_enforcement_coverage.mjs
dart run tool/architecture/check_ui_composition_contracts.dart --check
```

The first command rebuilds and seeds the plugin, including generated steering
probes. The drift gate rejects analyzer-plugin setup errors and every remaining
Catch diagnostic; the resolved checker owns cross-file screen/shell conformance.
