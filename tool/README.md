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
- `marketing/`: app-derived website media manifests and screenshot sync checks.
- `platform/`: Apple/platform configuration helpers.
- `ui_capture/`: route inventory, capture coverage, and deterministic screen capture tooling.
- `remote_ops_manifest.json`: consolidated index for Firebase, App Check, data,
  CI/CD, and App Store/TestFlight operational surfaces.

## Scanner Family

The UI/design scanners are currently stable root wrappers because they are used
directly by cleanup passes and CI-style checks. Keep these wrapper names stable
even if their internals move into shared scanner helpers later.

Shared shell mechanics for repo-root setup, mode parsing, and dependency checks
live in `tool/lib/scanner_shell.sh`; scanner-specific matching rules stay in the
root wrapper until a larger scanner-engine consolidation is justified.

Use `--summary` for review-friendly output and `--count` for cheap automated
checks that only need a numeric debt signal.

## Remote Ops Manifest

`tool/remote_ops_manifest.json` is the remote-operations index. It does not
deploy or mutate anything; it groups the existing tools, workflows, docs, and
manual console dependencies by blast radius. Keep it current when adding Firebase
deploy targets, data repair tools, App Check/App Store console steps, or CI/CD
workflows.

```sh
node tool/check_remote_ops_manifest.mjs --check
node tool/check_remote_ops_manifest.mjs --list
```

## Synthetic Persona Projection

The sales demo persona catalog is projected into app-ready profile JSON before
UI capture, marketing, and golden-image consumers read it. The checked planned
asset projection lives at
`tool/demo/demo_seed/personas/us_nyc_sales_profile_projection.planned.json`.

```sh
node tool/demo/demo_ops.mjs persona-profile-projection --asset-statuses planned --output tool/demo/demo_seed/personas/us_nyc_sales_profile_projection.planned.json --check
node tool/demo/demo_ops.mjs persona-profile-projection --asset-statuses planned --output tool/demo/demo_seed/personas/us_nyc_sales_profile_projection.planned.json --update
```

## Stable Root Entrypoints

These wrappers intentionally stay at the top level because CI, release runbooks,
or muscle memory already depend on them:

- `tool/audit_registry.dart`
- `tool/check_data_contract.sh`
- `tool/check_design_tokens.sh`
- `tool/check_raw_color_sweep.sh`
- `tool/check_sizing.sh`
- `tool/check_ui_allow_debt.sh`
- `tool/check_ui_local_constant_wrappers.sh`
- `tool/check_ui_system_raw_values.sh`
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
