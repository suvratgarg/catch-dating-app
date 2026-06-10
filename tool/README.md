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
- `branding/`: native launcher and splash branding generators.
- `contracts/`: Firestore, schema, business-rule, and generated contract gates.
- `data/`: Firestore data validators, repair scripts, and backfills.
- `demo/`: demo seeding, demo operations, and demo seed fixtures.
- `design/`: visual review and design-preview entrypoints.
- `env/`: checked-in Dart define files for app environments.
- `firebase/`: Firebase project/config helper scripts.
- `host_discovery/`: organizer acquisition backlog, deterministic search plans,
  seed listing fixtures, and dedupe indexes for claimable organizer pages.
- `lib/`: shared Node helper modules for repo paths, CLI parsing, and Firebase project selection.
- Completed one-time migration tools are retired after prod verification; historical
  evidence lives in the audit registry and migration contract metadata.
- `marketing/`: app-derived website media manifests and screenshot sync checks.
- `platform/`: Apple/platform configuration helpers.
- `ui_capture/`: route inventory, capture coverage, and deterministic screen capture tooling.
- `remote_ops_manifest.json`: consolidated index for Firebase, App Check, data,
  CI/CD, and App Store/TestFlight operational surfaces.

## Analyzer-Backed UI Reports

The old UI/design shell scanners have been retired. Their stable root wrapper
names remain because cleanup passes, docs, and CI still call them, but the
matching policy now lives in `packages/catch_ui_lints` and is reported from
normal `flutter analyze --no-fatal-infos` output.

Use `--summary` for review-friendly output and `--count` for cheap automated
checks that only need a numeric debt signal.

## Analyzer Plugin Lints

Catch-owned UI lints live in `packages/catch_ui_lints` and use Dart's
`analysis_server_plugin` API. They are enabled from the top-level `plugins`
section in `analysis_options.yaml`, so violations surface through the normal
`flutter analyze` and IDE analyzer path instead of a separate scanner pass.
The Catch UI plugin runs across handwritten `lib/**` while exempting
`lib/core/theme/**` token definitions and generated code.

Smoke wrappers stay in `tool/` because CI needs deterministic proof that the
plugins are loaded:

- `tool/check_riverpod_lint.sh`
- `tool/check_catch_ui_lints.sh`

The migrated Catch UI drift reports are analyzer-output aggregators, not
standalone scanners:

- `tool/check_catch_ui_lint_drift.sh`
- `tool/check_sizing.sh`
- `tool/check_ui_allow_debt.sh`
- `tool/check_ui_local_constant_wrappers.sh`
- `tool/check_ui_system_raw_values.sh`

## Remote Ops Manifest

`tool/remote_ops_manifest.json` is the remote-operations index. It does not
deploy or mutate anything; it groups the existing tools, workflows, docs, and
manual console dependencies by blast radius. Keep it current when adding Firebase
deploy targets, data repair tools, App Check/App Store console steps, or CI/CD
workflows. Manual console entrypoints must include `owner`, `ticket`, and
`guardrail` metadata so unsafe additions cannot hide behind descriptive labels.

```sh
node tool/check_remote_ops_manifest.mjs --check
node tool/check_remote_ops_manifest.mjs --list
```

## Sales Demo Persona Profile Projection

The sales demo persona catalog is projected into app-ready profile JSON before
UI capture, marketing, and golden-image consumers read it. The checked planned
asset projection lives at
`tool/demo/demo_seed/personas/us_nyc_sales_profile_projection.planned.json`.
The command requires explicit `--asset-statuses`; use `--allow-empty` only when
auditing an intentionally empty status slice.

```sh
node tool/demo/demo_ops.mjs persona-profile-projection --asset-statuses planned --output tool/demo/demo_seed/personas/us_nyc_sales_profile_projection.planned.json --check
node tool/demo/demo_ops.mjs persona-profile-projection --asset-statuses planned --output tool/demo/demo_seed/personas/us_nyc_sales_profile_projection.planned.json --update
```

## Marketing App Screenshot Context

Marketing app screenshots are tracked by `tool/marketing/capture_manifest.json`.
The Figma/AI-friendly metadata shape is checked into
`tool/marketing/app_screenshots_design_context.json` so downstream consumers do
not depend on ad hoc stdout.

```sh
node tool/marketing/export_app_screenshots.mjs --check
node tool/marketing/export_app_screenshots.mjs --check-design-json
node tool/marketing/export_app_screenshots.mjs --update-design-json
```

## Host Discovery

Organizer discovery starts with a machine-readable candidate backlog, not public
pages. The initial batch lives at
`tool/host_discovery/candidate_batches/2026-06-10-initial-organizer-targets.json`
and is validated against `target_categories.json`, seed listing docs, and
dedupe keys.

```sh
node tool/host_discovery/validate_discovery_data.mjs
node tool/host_discovery/validate_discovery_data.mjs --check
node tool/host_discovery/plan_search_runs.mjs
node tool/host_discovery/plan_search_runs.mjs --check
node tool/host_discovery/generate_source_evidence.mjs
node tool/host_discovery/generate_source_evidence.mjs --check
node tool/host_discovery/check_index_readiness.mjs
node tool/host_discovery/check_index_readiness.mjs --check
node tool/host_discovery/export_seed_import_plan.mjs
node tool/host_discovery/export_seed_import_plan.mjs --check
node tool/host_discovery/apply_seed_import_plan.mjs --project catchdates-dev
node tool/host_discovery/apply_seed_import_plan.mjs --project catchdates-dev --write
node tool/run.mjs check --category host-discovery
```

The apply command is dry-run by default. Production writes require the explicit
prod guard:

```sh
node tool/host_discovery/apply_seed_import_plan.mjs --project catch-dating-app-64e51 --allow-prod --confirm-prod-project catch-dating-app-64e51
node tool/host_discovery/apply_seed_import_plan.mjs --project catch-dating-app-64e51 --write --allow-prod --confirm-prod-project catch-dating-app-64e51
```

Generated files are checked in so reviews can see exactly which candidates and
searches are active:

- `tool/host_discovery/generated/candidate_dedupe_index.json`
- `tool/host_discovery/generated/search_plan.json`
- `tool/host_discovery/generated/source_evidence.json`
- `tool/host_discovery/generated/index_readiness_report.json`
- `tool/host_discovery/generated/firestore_seed_import_plan.json`

## Design Tokens

The canonical UI primitive source is `design/tokens/catch.tokens.json`. It
generates the customer website token CSS, website font assets, and Flutter Dart
constants consumed by `lib/core/theme`.

```sh
dart run tool/design_tokens.dart
dart run tool/design_tokens.dart --check
node tool/run.mjs run design:tokens
node tool/run.mjs check design:tokens
```

## Stable Root Entrypoints

These wrappers intentionally stay at the top level because CI, release runbooks,
or muscle memory already depend on them:

- `tool/audit_registry.dart`
- `tool/check_data_contract.sh`
- `tool/check_catch_ui_lint_drift.sh`
- `tool/design_tokens.dart`
- `tool/check_sizing.sh`
- `tool/check_ui_allow_debt.sh`
- `tool/check_ui_local_constant_wrappers.sh`
- `tool/check_ui_system_raw_values.sh`
- `tool/check_riverpod_lint.sh`
- `tool/check_catch_ui_lints.sh`
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
