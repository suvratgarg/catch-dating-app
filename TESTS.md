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
