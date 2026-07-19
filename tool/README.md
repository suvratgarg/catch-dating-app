# Tooling

The `tool/` tree owns repository checks, generators, migrations, deploy helpers,
and bounded data-repair commands. Use `node tool/run.mjs` to discover, validate,
and run tools by stable id instead of memorizing file paths.

Durable business workflows do not belong here. Resumable workflow runs, work
items, leases, budgets, agent decisions, and receipts live in `operations/` and
are governed by `docs/operations_platform.md`. The existing organizer-intake,
host-discovery, and event-guide scripts are compatibility producers for Supply
Intake adapters; add new orchestration to `operations/`, not another tool
subtree. Stable workflow checks remain discoverable through
`operations:boundaries` and `operations:workflow-manifest` in
`tools_manifest.json`. `remote_ops_manifest.json` remains the separate inventory
for commands that can touch external systems.

```sh
node tool/run.mjs list
node tool/run.mjs list --category data
node tool/run.mjs check --manifest-only
node tool/run.mjs check audit:backend-errors
npm run audit:backend-errors:check
node tool/run.mjs check --category demo
node tool/run.mjs run demo:ops --help
```

## Layout

- `audit/`: repo audit and code catalog scripts.
- `agent/`: AI-agent context-pack and readiness checks for deterministic repo
  work.
- `branding/`: native launcher and splash branding generators.
- `contracts/`: Firestore, schema, business-rule, and generated contract gates.
- `copy/`: typed locale-catalog validation, ownership scanners, and generated
  structured product-copy sync tools.
- `data/`: Firestore data validators, repair scripts, and backfills.
- `demo/`: demo seeding, demo operations, and demo seed fixtures.
- `design/`: visual review and design-preview entrypoints.
- `env/`: checked-in Dart define files for app environments.
- `firebase/`: Firebase project/config helper scripts.
- `host_discovery/`: organizer acquisition backlog, deterministic search plans,
  seed listing fixtures, and dedupe indexes consumed through the legacy Supply
  Intake adapter. New workflow orchestration belongs in `operations/`.
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
repository-root `dart analyze --format machine` output. In this workspace,
`flutter analyze` and `dart analyze lib` do not load the Catch plugin; never
use either command as proof that a Catch UI rule is clean.

Use `--summary` for review-friendly output, `--count` for cheap automated
checks that only need a numeric debt signal, and
`tool/check_catch_ui_lint_drift.sh --all --json <path>` when a cleanup pass
needs a reusable drift snapshot artifact with analyzer completion status.
The drift helper parses the machine analyzer diagnostic-code field; it must not
count `catch_*` text from filenames, symbol names, or diagnostic messages.

`bash tool/widget_cleanup_scan.sh --check` is the checked broad-cleanup ratchet.
Only the eight remaining regex-only categories live there. Promoted categories
are analyzer rules with seeded fixture parity, and
`tool/audit/catch_ui_lint_drift_baseline.json` owns their decrease-only counts.

## Analyzer Plugin Lints

Catch-owned UI lints live in `packages/catch_ui_lints` and use Dart's
`analysis_server_plugin` API. They are enabled from the top-level `plugins`
section in `analysis_options.yaml`. The deterministic CLI load path is a
repository-root `dart analyze`; CI caches that one machine-diagnostic census
and applies each severity gate to the exact diagnostic-code field.
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

The component registry generates the plugin steering tables and steering
probes through `tool/design/build_lint_enforcement_tables.mjs`. The
bidirectional coverage gate rejects undecided components, orphan codes, stale
generated output, and expired waivers. Cross-file shell/top-bar/state policy is
resolved by `tool/architecture/check_ui_composition_contracts.dart`.

## Where Enforcement Lives

- Analyzer diagnostics live in `packages/catch_ui_lints` and are probe-tested
  through `tool/check_catch_ui_lints.sh`.
- Repo scanners with audit-registry awareness live in `tool/architecture/*.mjs`
  and ship with Node `*.test.mjs` coverage.
- Dart classification scanners live in `tool/audit/*.dart`.
- Meta-gates that validate other tools live at the `tool/` root.
- Checks that need the Flutter toolchain gate directly in
  `.github/workflows/flutter-ci.yml`; pure Node and Bash gates run through
  `tools-ci.yml` manifest categories.

Composite Firestore query/index parity is owned by
`tool/contracts/check_firestore_query_indexes.mjs`. Repository query builders
declare ordered `firestore-index` contracts next to the query; the gate scans
all handwritten repository sources and validates the declared shapes against
`firestore.indexes.json`. Run it through
`node tool/run.mjs check contracts:firestore-query-indexes`.

New scanners must ship with a manifest `role`, `rules`, `vacuityProof`, and a
test containing a known-bad fixture.

## Riverpod Provider Graph

`tool/architecture/provider_graph.dart` parses every handwritten Dart AST under
`lib/` and generates the durable provider topology under
`docs/generated/provider_graph/`. The JSON includes generated and handwritten
providers, aliases, families, consumers, provider operations, overrides, and
Riverpod experimental Mutations. The HTML supports feature exploration and
one-hop provider inspection; the Mermaid file is the aggregated feature map.

```sh
dart run tool/architecture/provider_graph.dart --write
dart run tool/architecture/provider_graph.dart --check
dart run tool/architecture/provider_graph.dart --summary
```

Architecture candidates are exhaustively reviewed in
`tool/architecture/provider_graph_reviews.json`. The gate rejects stale output,
cycles, unresolved provider-internal references, new unreviewed relationships,
and obsolete review entries.

## Repository Hygiene

`tool/repository_root_manifest.json` is the exact ownership contract for every
repository-root entry. The gate rejects unclassified or multiply classified
entries, prohibited roots, unsafe cleanup targets, and machine-local Markdown
links. The cleaner is dry-run by default and refuses tracked, protected,
symlinked, or path-escaping targets; mutation additionally requires an explicit
scope.

```sh
node tool/check_repository_root_hygiene.mjs
node --test tool/check_repository_root_hygiene.test.mjs
node tool/repository_hygiene.mjs --scope evidence --json
# Apply only after reviewing the dry-run output:
node tool/repository_hygiene.mjs --scope evidence --apply --json
```

## Git Reconciliation And Document-Version Gates

Large reconciliation merges use an exact four-tree classifier. It distinguishes
discarded sides from equivalent resolutions and requires a reasoned receipt for
every exact discard in strict mode:

```sh
node tool/git/audit_merge_drops.mjs \
  --base <merge-base> --ours <pre-merge-ours> \
  --theirs <integrated-tip> --merged <result> \
  --receipt <receipt.json> --strict --json
node --test tool/git/audit_merge_drops.test.mjs
```

Governed document versions may increase or remain unchanged, but may not
decrease or silently lose their catalog entry/path metadata. The target defaults
to the working tree:

```sh
node tool/docs/check_doc_version_monotonic.mjs --base origin/main
node tool/docs/check_doc_version_monotonic.mjs --self-test
node --test tool/docs/check_doc_version_monotonic.test.mjs
```

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

## Installable App Targets

`tool/app_targets.json` is the checked Consumer/Host × dev/staging/prod target
matrix. Build wrappers and Apple flavor generation resolve identity from it;
the app-target gate reconciles the remaining native, Firebase, capability,
deep-link, force-update, and release surfaces. Each target has its own explicit
composition entrypoint (`main_<role>_<environment>.dart`); aggregate Android
build tasks and caller-supplied wrapper arguments that cannot resolve exactly
one target fail before compilation.

```sh
node tool/platform/resolve_app_target.mjs --role host --environment prod
node tool/run.mjs check platform:app-targets
node tool/run.mjs check platform:verify-ios-release-identity
```

The release-identity verifier accepts an `.xcarchive` or exported `.app` and
checks compiled target markers, version/build, embedded Firebase identity and
OAuth URL scheme, plus role-specific signed entitlements. GitHub and Xcode
Cloud run it before distribution and persist JSON receipts.

`Mobile Internal Release` is the canonical merge-driven internal store workflow. Its iOS
and Android jobs both resolve Consumer/Host identity from the manifest. Android
release jobs additionally run `platform:verify-android-release-identity` before
any guarded `qa`-track upload:

```sh
node tool/run.mjs check \
  platform:app-targets \
  platform:mobile-build-number \
  platform:verify-ios-release-identity \
  platform:verify-app-store-build \
  platform:verify-ios-processing-receipts \
  platform:verify-android-release-identity \
  platform:probe-google-play-access
```

The Android gate uses a checksum-pinned bundletool jar and compares the compiled
target, role, Firebase, Maps, debug, package, version, and upload-certificate
identity. `platform:verify-app-store-build` prevents a non-monotonic Apple build
and waits for exact App Store processing; `platform:verify-ios-processing-receipts`
binds Xcode Cloud retirement to those GitHub run artifacts.
`platform:upload-google-play-bundle` refuses the production track and requires
explicit `--apply --allow-prod`. `platform:xcode-cloud-workflow-state` is a
guarded cutover operation, not a routine release command.

Before flipping `GOOGLE_PLAY_UPLOAD_ENABLED`, dispatch the workflow with
`probe_play_access=true`, `app_role=both`, and `platform=android`. The
`platform:probe-google-play-access` gate creates and deletes an uncommitted edit
for each `qa` track; it never uploads a bundle or commits a release.

Do not add a bundle id, Firebase app id, native flavor, or store product only to
a workflow or platform file. Add it to the target contract and make the
consumer query or checker change in the same pass.

### Firebase deploy and client-callable gates

`tool/firebase/plan_firebase_deploy_targets.mjs` is the pure planner behind
`tool/deploy_firebase_targets.sh`. It validates target syntax, expands logical
Functions from source exports, keeps exact `functions:<name>` targets in the
Functions-first phase, and fails empty plans before any remote command runs.
The deploy wrapper synchronizes live callable Cloud Run invoker bindings after
the Functions phase and before indexes or rules.

`tool/firebase/client_callable_dependencies.json` declares production client
features that require a callable. The static checker reconciles the Dart define,
`AppConfig`, and Functions export. Release workflows add `--verify-live` so an
enabled dependency must reach the Firebase callable adapter before archive:

```sh
node --test tool/firebase/plan_firebase_deploy_targets.test.mjs
node tool/firebase/check_client_callable_dependencies.mjs \
  --role host --environment prod
```

Do not enable a production callable-backed client flag in the same release step
that first creates the backend. Deploy and prove the backend while the flag is
dark, then enable the client in a later merge.

## App Check Debug Tokens

Local simulator App Check debug tokens are registered through a narrow helper
that reads `FIREBASE_APP_CHECK_DEBUG_TOKEN` from the environment or `.env.local`
without printing it:

```sh
node tool/firebase/register_app_check_debug_token.mjs --env dev --role host --platform ios
./tool/run_host_dev_simulator.sh "iPhone 17 Pro"
```

Do not set `DISABLE_AUTH_APP_VERIFICATION_FOR_TESTING=true` for real
phone-number verification. That flag is only for Firebase test phone numbers.

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

## Marketing Website Route Contracts

Public marketing website routes are tracked in `design/website/routes.json` and
validated against the React route shell, `website/src/content/meta.json`, its
runtime validator, postbuild static output, and generated organizer listings.

```sh
node tool/marketing/check_website_routes.mjs --check
node --test tool/marketing/website_meta_contract.test.mjs
node tool/run.mjs check marketing:website-routes
```

Organizer listing generation produces two explicit projections: deployable
`website/src/generated/hostListings.json` excludes `catchDemo`, while
`hostListings.demo.json` includes demo records for Storybook and sales tooling.
`npm --workspace catch-marketing run check:organizer-listings` validates both.

## React Web Architecture Gates

The React website/admin surfaces share scanners for route ownership, UI
primitive ownership, governed component families, and server-state ownership.
The query-state scanner is a baseline-backed ratchet: current manual async
state candidates are listed in `tool/web/react_query_state_baseline.json`, and
new feature controller or `use*` hook loading/saving/submitting/in-flight state
fails the check unless it is intentionally baselined in an audit pass.

```sh
node tool/run.mjs check web:react-architecture-boundaries
node tool/run.mjs check web:react-ui-primitives
node tool/run.mjs check web:react-component-governance
node tool/run.mjs check web:react-query-state
node tool/run.mjs check web:shared-ui-adoption
node tool/run.mjs check web:react-controller-test-targets
node tool/run.mjs check web:react-dependency-graph
npm run web:ui:test
npm run web:ui:typecheck
```

`web:react-dependency-graph` generates the reviewable website/admin/web-ui
topology under `docs/generated/react_dependency_graph/`. It blocks unresolved
repo-local imports, direct website-to-admin dependencies, and stale generated
artifacts while keeping current strongly connected components visible as
report-only debt. Refresh deliberately with
`node tool/web/react_dependency_graph.mjs --write`.

`web:shared-ui-adoption` reconciles the cross-surface decision tracker with
website/admin runtime exports and `@catch/web-ui`. Adopted entries must be used
through both surface adapters. The same gate also preserves the shared focus,
accessible table/field/button contracts, and package CI path coverage.

`web:react-controller-test-targets` keeps every feature controller and mutation
hook classified in `tool/web/react_controller_test_targets.json`. Promoted
targets need a named importing behavior suite; planned targets remain visible
without turning aggregate coverage percentages into a brittle merge gate.

Registry-ready Storybook stories also have deterministic desktop and mobile
image baselines under `design/visual_baselines/<surface>/<platform>/`. Build
the relevant Storybook before comparing or intentionally updating them:

```sh
npm --workspace catch-marketing run build:storybook
node tool/web/check_storybook_visuals.mjs --surface website --check
node tool/web/check_storybook_visuals.mjs --surface webui --check
npm --workspace catch-admin run build:storybook
node tool/web/check_storybook_visuals.mjs --surface admin --check
# Limit a baseline update/check to task-owned registry entries in a dirty refactor.
node tool/web/check_storybook_visuals.mjs --surface admin --component workspace_intake_operations --update
```

Use repeatable `--component <registry-id>` filters to isolate a task-owned
visual check or baseline update. Use `--update` only after the target UI and
registry review states are final. The checker fixes both viewports, requests
reduced motion, waits for fonts, and compares only against the current
operating system's baselines. This separation is required because the product
intentionally uses `system-ui`, whose glyph metrics and rasterization differ
between Darwin and Linux. A mismatch writes both the rendered image and its
diff under `artifacts/visual-actuals/<surface>/<platform>/` and
`artifacts/visual-diffs/<surface>/<platform>/`.

The Admin Website and Marketing Website workflows pin the blocking Linux
capture to Ubuntu 24.04. Their manual `workflow_dispatch` input
`update_visual_baselines=true` captures Linux baselines and uploads them as a
review artifact; it does not commit them. Review that artifact before replacing
`design/visual_baselines/<surface>/linux/`. Local Darwin updates remain useful
for local visual review but never substitute for the Linux CI baseline.

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

## Agent Harness

The agent harness turns project instructions into small context packets and
validation gates. Use it before broad cleanup, architecture refactors, docs
consolidation, design-parity work, and any task where an agent needs to preserve
hard-won prior fixes.

```sh
node tool/agent/context_pack.mjs --task architecture-refactor --paths lib/events,lib/explore
node tool/agent/context_pack.mjs --task doc-hygiene --paths docs --json
node tool/agent/check_agent_readiness.mjs
node tool/agent/check_agent_readiness.mjs --record-metric
node tool/agent/record_delegation_outcome.mjs --task-id example --mode worker-patch --status integrated --parent-review-outcome accepted --dry-run
node tool/run.mjs check --category agent
```

`AGENTS.md` is the short entrypoint. Durable process guidance lives in
`docs/agent_operating_model.md`, regression guards in
`docs/agent_regression_ledger.json`, project-local skill routers in
`docs/agent_skills/`, and trendable measurements in
`docs/audit_registry/agent_metrics.jsonl`.
When using parallel agents, keep subagent work in disposable Git worktrees and
record the parent-reviewed result with
`tool/agent/record_delegation_outcome.mjs`.

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

## Product Copy

Short Flutter UI copy is owned by `lib/l10n/app_en.arb`. Structured content
that must remain usable by synchronous domain models is owned by locale JSON
under `copy/` and generates deterministic Dart. For Event Success
questionnaires:

`tool/copy/check_mobile_copy_ownership.dart` enforces that boundary across
widget arguments, copy-shaped constructor defaults and initializers,
presentation-state members, validator/share/status helpers, and Event Success
display enums. Its self-test seeds each supported AST shape plus technical and
diagnostic counterexamples. The product-copy baseline stays empty; the narrow
allowlist is reserved for proven technical identifiers.

`tool/copy/check_mobile_copy_catalog.mjs` also rejects new ARB identifiers that
contain the generated `Visiblecopy` marker. Reviewed legacy exceptions live in
`tool/copy/mobile_copy_identifier_allowlist.json`; additions require an explicit
review instead of silently expanding the catalog.

```sh
node tool/copy/check_l10n_key_usage.mjs --write-inventory
node tool/run.mjs check copy:l10n-key-usage
node --test tool/copy/check_l10n_key_usage.test.mjs
```

The key-usage inventory records exact handwritten Dart references, excludes
generated Dart/comments/string contents, and fails on any new orphan or stale
checked evidence. Baseline reductions pass; baseline growth is rejected.

```sh
node tool/copy/sync_event_success_questionnaires.mjs --write
node tool/run.mjs check copy:event-success-questionnaires
```

Event Success playbooks, coach guidance, and event-policy descriptions use the
same ownership model. Marketing edits `copy/structured_domain_copy_en.json`;
engineers edit typed structure templates only when the data model changes:

```sh
dart run tool/copy/sync_structured_domain_copy.dart --write
node tool/run.mjs check copy:structured-domain-content
```

Edit the JSON source, never the generated Dart file. The check validates stable
ids, non-empty text, and exact generated output.

## Adding Or Moving A Tool

1. Put the implementation in the narrowest matching category folder.
2. Add or update the entry in `tool/tools_manifest.json`.
3. Include at least one cheap `checks` command unless the tool is an interactive Flutter entrypoint.
4. Use `tool/lib/` helpers for repo paths, CLI flags, and Firebase project selection.
5. Run `node tool/run.mjs check --manifest-only` before opening a PR.

Remote write tools should default to dry-run/read-only behavior, require an
explicit apply flag, and carry a `safety` label that reflects the blast radius.
