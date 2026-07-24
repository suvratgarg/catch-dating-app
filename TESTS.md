# Catch Test Inventory

The machine-readable inventory is generated from tracked files, so this document does not maintain a manual filename list.

```sh
node tool/test_inventory.mjs          # regenerate
node tool/test_inventory.mjs --check  # fail on drift
```

See [docs/audit_registry/test_inventory.json](docs/audit_registry/test_inventory.json) for counts and paths grouped into Flutter unit/widget, Flutter integration, Functions source, Firebase rules, Functions harness, React web, and repository-tooling tests.

## Standard suites

```sh
flutter test
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
probes. The drift ratchet rejects analyzer-plugin setup errors and baseline
increases; the resolved checker owns cross-file screen/shell conformance.
