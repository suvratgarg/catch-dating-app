# Tooling

The `tool/` tree is organized by operational ownership. Use `node tool/run.mjs`
to discover, validate, and run tools by stable id instead of memorizing file
paths.

```sh
node tool/run.mjs list
node tool/run.mjs list --category data
node tool/run.mjs check --manifest-only
node tool/run.mjs check --category demo
node tool/run.mjs run demo:ops --help
```

## Layout

- `audit/`: repo audit and code catalog scripts.
- `contracts/`: Firestore, schema, business-rule, and generated contract gates.
- `data/`: Firestore data validators, repair scripts, and backfills.
- `demo/`: demo seeding, demo operations, and demo seed fixtures.
- `design/`: visual review and design-preview entrypoints.
- `env/`: checked-in Dart define files for app environments.
- `firebase/`: Firebase project/config helper scripts.
- `lib/`: shared Node helper modules for repo paths, CLI parsing, and Firebase project selection.
- `migrations/`: historical one-time migrations kept for auditability.
- `platform/`: Apple/platform configuration helpers.

## Stable Root Entrypoints

These wrappers intentionally stay at the top level because CI, release runbooks,
or muscle memory already depend on them:

- `tool/audit_registry.dart`
- `tool/check_data_contract.sh`
- `tool/deploy_firebase_targets.sh`
- `tool/firebase_with_env.sh`
- `tool/flutter_with_env.sh`
- `tool/use_firebase_environment.sh`
- `tool/validate_firebase_environment.sh`
- `tool/widget_cleanup_scan.sh`
- `tool/write_ios_maps_key_xcconfig.sh`

## Adding Or Moving A Tool

1. Put the implementation in the narrowest matching category folder.
2. Add or update the entry in `tool/tools_manifest.json`.
3. Include at least one cheap `checks` command unless the tool is an interactive Flutter entrypoint.
4. Use `tool/lib/` helpers for repo paths, CLI flags, and Firebase project selection.
5. Run `node tool/run.mjs check --manifest-only` before opening a PR.

Remote write tools should default to dry-run/read-only behavior, require an
explicit apply flag, and carry a `safety` label that reflects the blast radius.
