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
(cd widgetbook && flutter analyze --no-fatal-warnings --no-fatal-infos && flutter build web --release)
npm --prefix functions test
npm --prefix functions run test:rules
npm run web:typecheck
node tool/run.mjs check --category meta
```

Use focused tests while iterating, then run the owning surface's full gate before handoff. Never run multiple Flutter analyzer/test processes concurrently. Add regression coverage beside the owned surface and make recurring architectural rules enforceable through the tool manifest.

`.github/workflows/flutter-ci.yml` compiles Widgetbook on every relevant Flutter
change. `.github/workflows/visual-integration-ci.yml` runs exact desktop goldens
and deterministic headless app-shell wrappers sequentially on macOS for relevant
changes, on weekdays, and on manual dispatch; failed golden images are retained
as CI artifacts. Pass a device id to the runner (for example,
`bash tool/test_app_shell_integration.sh macos`) for an explicit native-device
pass. Live Firebase/device evidence remains a release-runbook lane rather than
being implied by repository integration tests.

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
