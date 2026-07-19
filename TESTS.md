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
flutter test integration_test
npm --prefix functions test
npm --prefix functions run test:rules
npm run web:typecheck
node tool/run.mjs check --category meta
```

Use focused tests while iterating, then run the owning surface's full gate before handoff. Never run multiple Flutter analyzer/test processes concurrently. Add regression coverage beside the owned surface and make recurring architectural rules enforceable through the tool manifest.

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
