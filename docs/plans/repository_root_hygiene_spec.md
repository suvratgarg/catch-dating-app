---
doc_id: repository_root_hygiene_spec
version: 1.0.0
updated: 2026-07-23
owner: repository_hygiene
status: retirement_ready
reviewers:
  - Fable
  - repository owner
---

# Repository Root Hygiene & Cleanup — Fable Review Spec

## 0. Historical review request

This document converted the 2026-07-12 project-root audit into an executable
cleanup and governance proposal. It is retained as historical review evidence;
current behavior is owned by the enforcement and owner docs named in §18.

Fable is being asked to review:

1. whether each root entry has the right owner and placement;
2. whether the proposed tracked artifact and design-reference policy preserves
   material that still has product or design value;
3. whether the documentation consolidation keeps enough context for future
   design and engineering work;
4. whether the default cleanup/retention thresholds are appropriate; and
5. whether any proposed deletion should instead become a labeled historical
   reference.

Engineering implementation began after the dispositions in §14 were recorded
and the remaining owner choices were closed on 2026-07-19.

> Review recorded 2026-07-12 (spec v0.2.0): Fable dispositions are filled in
> §14 and the corrections/additions from that review are folded into §§1, 2,
> 7, 9, 11, 12, 13, and 16. The former `pending-owner` rows were resolved in
> the closeout column below.

## 1. Executive summary

The root is not architecturally chaotic. It is a reasonable hybrid monorepo:

- Flutter owns the repository root.
- `admin/` and `website/` are declared npm workspaces.
- `functions/` is the Firebase Functions package configured by `firebase.json`.
- `widgetbook/` is a separate Flutter component-catalog application.
- `contracts/`, `copy/`, `design/`, `firebase/`, and `tool/` are legitimate
  cross-runtime sources of truth.

The actual problems are different:

1. **Physical bloat:** approximately 59.6 GiB of the 60.54 GiB checkout is
   reproducible build, cache, dependency, capture, or audit output.
2. **Legacy residue:** `.audit_work/`, root logs, and most of `codex_audit/`
   no longer carry active source-of-truth value.
3. **Mixed artifact ownership:** `artifacts/` combines curated tracked media,
   an unreferenced concept render, and ignored high-churn captures without a
   root policy.
4. **Documentation drift:** root entrypoint docs overlap, contain 127
   machine-specific absolute links, and include a broken test inventory.
5. **Missing enforcement:** the repo has no root-entry allowlist, safe cleanup
   command, artifact-retention policy, or portability scanner to prevent the
   same accumulation from returning.
6. **Local deploy footgun:** Firebase's `default` alias resolves to
   production, and `functions/package.json` exposes raw `firebase deploy` /
   `firebase functions:log` scripts that ride it. CI is already
   wrapper-gated (`tool/firebase_with_env.sh`,
   `tool/deploy_firebase_targets.sh`, emulator runs pinned to
   `demo-catch-rules`), so the exposure is local/interactive only — still
   worth closing, but it is not an operational CI gap.

### Recommended direction

Use two distinct tracks:

- **Local housekeeping:** preview and remove only ignored, reproducible data;
  record before/after bytes but create no source commit.
- **Tracked root governance:** retire stale tracked artifacts, consolidate root
  docs, add an artifact policy, and introduce manifest-backed scanners and a
  protected cleanup tool.

Do **not** reorganize the repository into `apps/`/`packages/`, move the Flutter
root, or relocate the active `design_context_pack/` merely to make the root look
shorter. Those changes would create high churn without fixing the actual
ownership problem.

## 2. Evidence baseline

Snapshot captured locally on 2026-07-12. These values are evidence for review,
not permanent thresholds. Remeasure immediately before implementation.

| Measurement | Current value | Interpretation |
|---|---:|---|
| Top-level entries, including hidden entries | 74 | Manageable if every entry is classified and enforced. |
| Checkout disk usage | 60.54 GiB | Dominated by local generated state. |
| Root `build/` | 53.73 GiB | Reproducible; `build/test_cache` is roughly 39 GiB. |
| Flutter/Dart/Widgetbook caches | 2.48 GiB | Reproducible. |
| Native caches and builds | 2.40 GiB | CocoaPods, Android Gradle, iOS build output, and symlinks. |
| Node dependencies and web outputs | 0.84 GiB | Reproducible workspace dependencies and build/Storybook output. |
| Audit/capture residue | 0.18 GiB | Ignored audit, capture, and dedupe output. |
| Nested Claude worktrees | 0.43 GiB | Stateful; two registered worktrees were clean at audit time. |
| Prunable Git worktree registrations | 30 | Metadata only; dry-run reported missing worktree locations. |
| Machine-specific Markdown links in root docs | 127 | Links contain `/Users/suvratgarg/...` and do not work for other clones. |
| Flutter tests found recursively | 222 | Current live count at audit time. |
| Flutter tests found by `TESTS.md` command | 217 | The documented command misses five nested tests. |
| Files found by the Functions `TESTS.md` command | 2,003 | It traverses `node_modules`; only 85 tracked Functions test files matched the focused Git query. |

### Verification evidence used for this spec

- `git status --short --branch` was clean before the spec pass.
- `git count-objects -vH` reported zero Git garbage.
- `git worktree prune --dry-run --verbose` reported 30 prunable registrations.
- `node tool/run.mjs check --manifest-only` passed before this spec was written.
- `node tool/agent/check_agent_readiness.mjs` reported 100/100 before this
  spec was written.

### Fable verification additions (2026-07-12)

- `git ls-files -i -c --exclude-standard` returned zero tracked-but-ignored
  files, so scanner check 3 in `ROOT-HYGIENE-010` can block from day one with
  no grandfathering.
- `artifacts/marketing/app-screenshots` has live consumers
  (`admin/src/features/marketing/assets/marketingAppScreenshotAssets.ts`, the
  `tool/marketing/` pipeline and ops bridge), so §9's "keep while referenced"
  condition is grounded.
- Nothing outside this spec references `artifacts/host-page-render/`;
  deletion needs no migration.
- All 30 prunable worktree registrations point at purged
  `/private/tmp/catch-*` paths; the three surviving `/tmp` worktrees were
  clean and pushed at review time. See the root-cause policy in
  `ROOT-HYGIENE-002`.
- CI Firebase usage is already environment-wrapped; only local scripts and
  interactive commands ride the `default` alias. See the reframed
  `ROOT-HYGIENE-013`.

## 3. Goals

1. Make every top-level entry explainable from one checked manifest.
2. Reclaim reproducible disk usage without risking credentials, signing state,
   active worktrees, or source artifacts.
3. Separate curated/tracked evidence from disposable/generated evidence.
4. Retire completed or orphaned root artifacts after human review.
5. Reduce root documentation overlap while preserving canonical ownership.
6. Replace manual root hygiene with scanners, tests, and an explicit cleanup
   command.
7. Prevent raw commands from accidentally targeting production Firebase.
8. Leave a deterministic audit receipt with before/after proof.

## 4. Non-goals

- Moving the main Flutter app into `apps/mobile/`.
- Moving `admin/`, `website/`, `functions/`, or `widgetbook/` solely for visual
  symmetry.
- Replacing npm workspaces, Flutter tooling, Firebase CLI conventions, or the
  audit registry.
- Deleting `.env`, `.env.local`, signing files, Firebase configs, or any active
  worktree.
- Deleting or relocating `design_context_pack/` without an independent design
  pipeline decision.
- Refactoring application behavior under `lib/`, `functions/src/`, `admin/src/`,
  or `website/src/` as part of root hygiene.
- Treating ignored files as inherently safe to delete.
- Using `git clean -fdX` or another broad, policy-blind deletion command.

## 5. Root-entry classification model

Every root entry should declare exactly one primary kind:

| Kind | Meaning | Tracking policy | Cleanup policy |
|---|---|---|---|
| `source` | Product code, assets, schemas, or a first-class subproject | Tracked | Never automatically deleted. |
| `config` | Toolchain, CI, deploy, lint, localization, or workspace configuration | Tracked | Never automatically deleted. |
| `documentation` | Human or agent source-of-truth documentation | Tracked | Consolidate through doc hygiene; never cache-cleaned. |
| `protected-local` | Secrets, signing inputs, IDE-local settings, or active worktree state | Ignored | Never automatically deleted. |
| `generated-cache` | Fully reproducible dependency/build/cache output | Ignored | Previewable and cleanable from an exact allowlist. |
| `generated-evidence` | Reproducible screenshots, reports, logs, or analysis intermediates | Ignored unless intentionally curated | Retention-managed; promote deliberately before cleaning. |
| `curated-artifact` | Versioned output intentionally consumed or reviewed | Tracked | Keep while its manifest/consumer remains active. |
| `legacy` | Completed, orphaned, duplicated, or superseded material | Tracked or ignored | Delete or archive after explicit review. |

Placement alone is not the policy. A generated directory may validly live at
the root when it is a checked deliverable, while an ignored file may still be
protected state.

## 6. Complete root inventory and disposition

The grouped rows below account for all 74 top-level entries present in the
snapshot.

### 6.1 Local and generated entries

| Entry | Function | Kind | Proposed disposition |
|---|---|---|---|
| `.DS_Store` | macOS Finder metadata | `generated-cache` | Delete; prohibit in the root manifest. |
| `.audit_work/` | Deep semantic audit scratch JSON/text | `generated-evidence` | Delete after confirming no active audit; future scratch uses OS temp or a named ignored artifact lane. |
| `.claude/` | Claude local settings, interactive-debug skill, nested worktrees | `protected-local` | Keep settings and skill. Report worktrees separately; never delete the whole directory. |
| `.dart_tool/` | Dart/Flutter dependency, build, test, and extension cache | `generated-cache` | Safe allowlisted cleanup when no Dart/Flutter job is running. |
| `.env` | Envied input for the Razorpay key id | `protected-local` | Keep. Add a committed placeholder template. |
| `.env.local` | Local App Check/debug flags and token | `protected-local` | Keep. Never print values or include in cleanup. |
| `.firebase/` | Firebase Hosting/CLI cache | `generated-cache` | Cleanable. |
| `.flutter-plugins-dependencies` | Generated Flutter plugin dependency graph | `generated-cache` | Cleanable. |
| `.idea/` | IntelliJ/Android Studio local project state | `protected-local` | Keep if useful; offer an opt-in IDE cleanup scope, not default cleanup. |
| `build/` | Flutter/native/test/build outputs | `generated-cache` | Highest-priority cleanup; warn locally above the approved size threshold. |
| `catch_dating_app.iml` | IntelliJ module metadata | `generated-cache` | Cleanable; IDE regenerates it. |
| `coverage/` | Flutter coverage output | `generated-evidence` | Cleanable with an explicit evidence scope. |
| `firestore-debug.log` | Firebase emulator log | `generated-evidence` | Delete when the emulator is stopped; add age/size retention. |
| `flutter_01.log`–`flutter_13.log` | Historical Flutter run logs | `generated-evidence` | Delete; prevent indefinite root accumulation. |
| `node_modules/` | Root npm workspace dependencies | `generated-cache` | Cleanable; regenerate with the lockfile. |

### 6.2 Repository control, documentation, and configuration

| Entry | Function | Kind | Proposed disposition |
|---|---|---|---|
| `.firebaserc` | Firebase aliases, hosting targets, extension etags | `config` | Keep; change or guard the production `default` alias per §14. |
| `.git/` | Git history, objects, refs, and worktree metadata | `protected-local` | Keep. Allow only Git-native maintenance; never filesystem-delete internals. |
| `.github/` | CI workflows and composite actions | `config` | Keep in place. |
| `.gitignore` | Secret and generated-output exclusions | `config` | Keep; add narrow patterns/negations accepted in §12. |
| `.metadata` | Flutter project and migration metadata | `config` | Keep tracked. |
| `AGENTS.md` | Short agent routing entrypoint | `documentation` | Keep; remains the primary agent entrypoint. |
| `CLAUDE.md` | Claude-specific routing entrypoint | `documentation` | Reduce to `AGENTS.md` plus Claude-only behavior; replace absolute links. |
| `PROJECT_CONTEXT.md` | Product, route, architecture, backend, and workflow map | `documentation` | Keep as a high-level map but substantially shorten after moving detail to existing owner docs. |
| `README.md` | Human setup and common-command entrypoint | `documentation` | Keep; reduce duplicated debug/release/error runbooks and use relative links. |
| `TESTS.md` | Test policy and inventory entrypoint | `documentation` | Keep or relocate only after a generated test inventory owns the live list; current commands are inaccurate. |
| `analysis_options.yaml` | Flutter lints and analyzer plugins | `config` | Keep. |
| `build.yaml` | Global `json_serializable` options | `config` | Keep. |
| `dart_test.yaml` | Test tag declaration, including `golden` | `config` | Keep. |
| `devtools_options.yaml` | DevTools extension configuration | `config` | Delete if it remains empty; otherwise document the intended extension. |
| `l10n.yaml` | Flutter localization generation contract | `config` | Keep. |
| `package.json` | npm workspaces and shared web/tool scripts | `config` | Keep. Add hygiene commands after tooling exists. |
| `package-lock.json` | npm workspace dependency lock | `config` | Keep. |
| `pubspec.yaml` | Main Flutter package, assets, fonts, dependencies | `config` | Keep. |
| `pubspec.lock` | Flutter/Dart dependency lock | `config` | Keep. |
| `firebase.json` | Firebase deploy, hosting, extension, emulator contract | `config` | Keep. |
| `firestore.indexes.json` | Firestore index contract | `config` | Keep. |
| `firestore.rules` | Firestore security rules | `config` | Keep. |
| `storage.rules` | Storage security rules | `config` | Keep. |

### 6.3 Source, subprojects, and first-class artifacts

| Entry | Function | Kind | Proposed disposition |
|---|---|---|---|
| `admin/` | React/Vite administrative application | `source` | Keep at root; clean only its ignored dependencies/build output. |
| `analytics/` | BigQuery DDL and mart-refresh SQL | `source` | Keep; `analytics/sql/README.md` is the local owner. |
| `android/` | Flutter Android platform, flavors, signing hooks, Gradle wrapper | `source` | Keep; protect signing/local files and clean only allowlisted caches. |
| `artifacts/` | Curated marketing assets plus ignored UI/dedupe output | Mixed | Keep the root, add `artifacts/README.md`, and classify subpaths per §9. |
| `assets/` | Runtime branding, fonts, fixture images, and audio | `source` | Keep. |
| `codex_audit/` | Legacy Codex trackers and ignored release evidence | `legacy` | Retire after Fable/owner disposition. Recommended default: delete, relying on Git history and audit receipts. |
| `contracts/` | JSON Schemas, fixtures, migrations, public/shared contracts | `source` | Keep as a first-class cross-runtime source. |
| `copy/` | Typed native, notification, questionnaire, and domain copy catalogs | `source` | Keep as a cross-runtime source. |
| `design/` | Design tokens, screen/component contracts, references, source packs | `source` | Keep as the canonical design-source tree. |
| `design_context_pack/` | Generated, manifested external design bundle | `curated-artifact` | Keep at root for now; it is CI-checked and consumed. Revisit placement only as a separate migration. |
| `docs/` | Canonical architecture, operations, design, and audit docs | `documentation` | Keep. |
| `extensions/` | Firebase Extension instance parameter files | `config` | Keep. |
| `firebase/` | Versioned dev/staging/prod Firebase configs and runbook | `config` | Keep. |
| `functions/` | Firebase Cloud Functions TypeScript package | `source` | Keep; clean ignored dependencies, compiled output, and logs only. |
| `integration_test/` | Flutter integration/device tests | `source` | Keep. |
| `ios/` | Flutter iOS platform, schemes, CI/release scripts | `source` | Keep; clean Pods/build/symlinks, not project/signing config. |
| `lib/` | Main Flutter application source | `source` | Keep. |
| `macos/` | Flutter macOS platform | `source` | Keep; clean Pods/ephemeral output only. |
| `packages/` | Catch UI lints, local icon fork, shared web config | `source` | Keep; clean nested build output only. |
| `test/` | Flutter unit, widget, golden, and tooling tests | `source` | Keep. |
| `tool/` | Manifested scripts, scanners, generators, deploy wrappers | `source` | Keep; owner of the proposed hygiene implementation. |
| `web/` | Flutter web platform bootstrap | `source` | Keep; distinct from `website/`. |
| `website/` | React/Vite public marketing website | `source` | Keep at root; clean ignored dependencies/build output only. |
| `widgetbook/` | Separate Flutter component-catalog application | `source` | Keep; clean ignored `.dart_tool` and `build` output only. |

## 7. Immediate local housekeeping tranche

This tranche changes no tracked source. It should be run only after a dry-run
report is reviewed and active build/emulator/Storybook processes are stopped.

### `ROOT-HYGIENE-001` — reproducible cache cleanup

Allowlist these categories:

- Flutter/Dart: `build/`, `.dart_tool/`, `.flutter-plugins-dependencies`,
  `widgetbook/build/`, `widgetbook/.dart_tool/`, nested package build output.
- Native: `android/.gradle/`, `android/.kotlin/`, `ios/Pods/`, `ios/build/`,
  `ios/.symlinks/`, `macos/Pods/`, platform ephemeral output.
- Node/web: root and nested `node_modules/`, `functions/lib/`, admin/website
  `dist/`, `storybook-static/`, and TypeScript build info.
- Evidence: `coverage/`, `.firebase/`, `.audit_work/`, ignored UI captures,
  ignored widget-dedupe fingerprints, and reviewed legacy logs.

Expected reclaim from the snapshot, excluding worktrees: approximately
59.6 GiB.

### `ROOT-HYGIENE-002` — worktree maintenance

- Run `git worktree prune --dry-run --verbose` and record the candidates.
- Prune missing worktree registrations through Git.
- For each real worktree under `.claude/worktrees/`, verify:
  `git status`, branch/detached state, HEAD, last activity, and whether any
  process still uses it.
- Remove a real worktree only with `git worktree remove <path>` after explicit
  confirmation.
- Never let the cleanup tool remove worktrees automatically.

Root cause and standing policy (Fable, 2026-07-12): every one of the 30
prunable registrations pointed at a `/private/tmp/catch-*` path. macOS
periodically purges `/private/tmp`, so worktrees created there die and leave
metadata behind; pruning alone treats the symptom. Adopt a placement policy:
agent and human worktrees live in a durable location (a sibling directory
outside the repository, or `.claude/worktrees/`, which is already ignored and
protected) — never under the OS temp root. The scanner's local report should
include the prunable-registration count as a drift signal, and Phase 0 must
triage any still-live `/tmp` worktrees (three existed at review time, all
clean and pushed) before OS temp cleanup races them.

### Protected exclusions

The cleaner must refuse these paths even if they are ignored:

- `.git/**`;
- `.env`, `.env.local`, `.env.*.local`;
- `.claude/settings.local.json` and `.claude/skills/**`;
- `android/key.properties`, `android/keystore/**`, `android/local.properties`;
- Apple certificates/profiles/keys and `ios/Flutter/GoogleMapsKeys.xcconfig`;
- active Git worktrees;
- tracked content or any path not declared cleanable in the manifest.

## 8. Legacy tracked-content decisions

### `ROOT-HYGIENE-003` — retire `codex_audit/`

Current state:

- `codex_audit/ui_cohesion_cleanup_todo.md` is tracked, all tasks are checked,
  and its final note incorrectly says the tracker is untracked.
- `codex_audit/release_setup_2026-04-30/logs/` is roughly 112 MiB of ignored
  release evidence.
- `codex_audit/catch_session_learning_pack_2026-04-28.zip` is ignored.
- `docs/config_cicd_platform_audit_2026-05-21.md` says the old
  `codex_audit` material was consolidated into durable docs.

Recommended disposition:

1. delete the completed tracked todo;
2. delete the ignored release logs and zip after owner confirmation;
3. remove the empty `codex_audit/` root;
4. rely on Git history plus `docs/audit_registry/passes.jsonl` for historical
   proof; and
5. make `codex_audit/` a prohibited root entry in the new manifest.

If Fable identifies still-useful visual/product material, migrate only that
material to its real owner with a historical label; do not retain the folder as
a miscellaneous archive.

### `ROOT-HYGIENE-004` — disposition `artifacts/host-page-render/`

This tracked directory contains an unreferenced static “Catch for Hosts”
concept page, CSS, and screenshots. It is not consumed by the current website,
design contracts, or build pipeline.

Recommended disposition: delete it after Fable confirms that it is not an
active design reference. If it remains valuable, move a deliberately selected
reference into the design-reference owner and label it historical/rejected or
approved; do not leave a runnable concept mixed with operational artifacts.

## 9. Artifact ownership and retention

### `ROOT-HYGIENE-005` — add `artifacts/README.md`

The README should declare:

| Subpath | Tracking | Owner | Retention/default |
|---|---|---|---|
| `artifacts/marketing/app-screenshots/*.png` | Tracked curated output | Marketing media pipeline | Keep while referenced by the admin bridge/content manifest. |
| `artifacts/marketing/app-screenshots/raw/**` | Ignored generated input | Marketing capture tooling | Retain only until curated outputs are approved; proposed 14 days. |
| `artifacts/ui-captures/**` | Ignored generated evidence | UI capture pipeline | Proposed 14-day local retention unless promoted to a tracked reference. |
| `artifacts/widget_dedupe/**` | Ignored generated evidence | Widget-dedupe tooling | Rebuild on demand; remove after the associated review/receipt closes. |
| `artifacts/host-page-render/**` | Currently tracked orphan | No active owner | Delete or migrate after Fable review. |

The policy must distinguish:

- **evidence used in a pass receipt** from **evidence that must be committed**;
- **curated consumer assets** from **raw generation inputs**; and
- **temporary review output** from **canonical design references**.

An audit receipt may name a regenerable ignored path without requiring that
every byte be retained indefinitely.

### Repo-wide evidence lanes (Fable addition, 2026-07-12)

`artifacts/` is not the only ignored-evidence lane. `.gitignore` already
names four more with the same ownership/retention ambiguity:

- `docs/visual_references/**` image dumps;
- `tool/organizer_intake/raw_artifacts/**`;
- `test/goldens/failures/`; and
- emulator exports (`firebase-export-*/`, `emulator-data/`).

The retention policy must either cover these lanes in the same pass or
explicitly scope itself to the root and open a tracked follow-up. Otherwise
the accumulation problem recurs one directory down while the root manifest
reports green.

### Retention executor (Fable addition, 2026-07-12)

A retention threshold nobody runs is ceremonial — the exact risk §16 names.
The default dry-run of `tool/repository_hygiene.mjs` must print retention
violations (path, age, bytes), and the local meta/agent-readiness report
should surface the violation count. CI remains excluded from size/age
enforcement.

### Explicit exception: `design_context_pack/`

Keep `design_context_pack/` as a tracked root deliverable for this tranche
because it has:

- a deterministic generator and `--check` mode;
- a checksum manifest;
- CI path wiring;
- active branding/design consumers; and
- a distinct external-upload use case.

Its placement may be reconsidered only with a migration that updates every
consumer, check, document, and manifest in one pass. It is not local garbage.

## 10. Documentation consolidation

### `ROOT-HYGIENE-006` — root entrypoint ownership

Proposed target responsibilities:

| File | Target responsibility | Proposed size/shape |
|---|---|---|
| `AGENTS.md` | Agent routing and required workflow only | Keep short; no duplicated architecture. |
| `CLAUDE.md` | Pointer to `AGENTS.md` plus Claude-specific behavior only | Roughly 5–15 lines; relative links. |
| `PROJECT_CONTEXT.md` | Product loop, stack, high-level map, route/data-owner links, sharp edges | Reduce materially from 1,091 lines; detailed contracts stay in owner docs. |
| `README.md` | Human first-run setup, core commands, surface map, safety notes | Reduce duplicated phone-debug, release, Firebase, and error runbooks. |
| `TESTS.md` | Test policy and generated inventory entrypoint | No hand-maintained list; all live inventory comes from tooling. |

Before removing a section, migrate only the still-current detail to an existing
owner such as:

- `docs/app_architecture.md`;
- `docs/data_contracts.md`;
- `docs/backend_operation_catalog.md`;
- `docs/release_operations.md`;
- `tool/README.md`; or
- the relevant feature README.

Do not create parallel architecture, testing, debug, or release docs merely to
make the root files shorter.

### `ROOT-HYGIENE-007` — portable Markdown links

Replace root-doc links containing `/Users/suvratgarg/...` with repository-
relative links. Add a scanner that fails on tracked Markdown links beginning
with common local-home prefixes such as `/Users/`, `/home/`, or `C:\\Users\\`,
while allowing explicitly labeled command output or historical evidence where
the path is not a Markdown destination.

The 2026-07-12 baseline is 127 machine-specific links across `CLAUDE.md`,
`PROJECT_CONTEXT.md`, and `README.md`; the target is zero portable-link
violations.

### `ROOT-HYGIENE-008` — trustworthy test inventory

Replace the current `find` commands with a tool that:

- uses Git-tracked source as the canonical inventory;
- separately reports Flutter unit/widget tests, integration tests, Functions
  source tests, emulator rules tests, web tests, and tooling self-tests;
- excludes dependencies and compiled output by construction;
- has a `--check` mode for stale documentation/registries;
- emits stable JSON for tooling and a concise human summary; and
- is registered in `tool/tools_manifest.json`.

The test inventory should not require manually updating every filename in
Markdown.

## 11. Root manifest, scanner, and cleaner design

### `ROOT-HYGIENE-009` — checked root manifest

Add `tool/repository_root_manifest.json` with a versioned schema. Each entry or
pattern should declare at least:

```json
{
  "path": "build",
  "kind": "generated-cache",
  "owner": "flutter-toolchain",
  "tracking": "ignored",
  "cleanup": "allowlisted",
  "protected": false,
  "reason": "Flutter and native build output"
}
```

Optional local-only metadata may include `warnBytes`, `retentionDays`, or a
specific generator/recovery command. Do not encode developer-specific absolute
paths.

The manifest must classify all expected top-level entries and explicit dynamic
patterns — at minimum `flutter_*.log`, `firestore-debug.log`,
`firebase-export-*/`, `emulator-data/`, and `*.iml`. The prohibited-name list
must include `catch-dating-app/` (the known accidental nested project already
present in `.gitignore`) alongside `codex_audit` and `.audit_work`. An unknown
new root entry should fail the scanner until it receives an owner and policy.

Use one owner vocabulary across the repository: the manifest `owner` field,
docs front-matter `owner:` slugs, and `tool/tools_manifest.json` ownership
should share the same slug set so ownership stays queryable across docs,
tools, and root entries.

### `ROOT-HYGIENE-010` — CI scanner

Add `tool/check_repository_root_hygiene.mjs` plus unit tests and known-good/
known-bad fixture trees. Its CI-safe checks should include:

1. every current root entry matches exactly one manifest entry/pattern;
2. tracked/ignored expectations match Git;
3. no tracked file is also ignored;
4. protected entries are never declared cleanable;
5. retired root names such as `codex_audit` and `.audit_work` cannot return;
6. required owner docs and recovery commands exist;
7. curated-artifact entries declare their consumer or manifest; and
8. tracked Markdown passes the portable-link check.

Disk size and age should be reported locally but should not fail CI, because CI
workspace/cache characteristics differ from developer machines.

Register the scanner in `tool/tools_manifest.json` with:

- a stable tool id such as `repo:root-hygiene`;
- role `gate`;
- a known-bad vacuity proof; and
- a unit-test command proving unexpected, protected-cleanable, and tracking-
  mismatch cases fail.

### `ROOT-HYGIENE-011` — protected cleanup command

Add `tool/repository_hygiene.mjs` with these contracts:

- default mode is report/dry-run;
- mutation requires `--apply` and a named scope;
- every deletion resolves to a manifest entry marked `allowlisted`;
- resolved paths must remain inside the repository and must not cross a
  symlink boundary;
- tracked files, protected paths, and worktrees are hard failures;
- output lists paths, reasons, and bytes before deletion;
- worktree cleanup is advisory only and prints Git-native commands;
- no shell glob is passed to a broad deletion command;
- failures are non-partial where feasible, with a preflight before mutation;
- `--json` provides a machine-readable report; and
- fixture-based tests prove protected data survives every scope.

Suggested scopes:

- `flutter`;
- `native`;
- `node`;
- `evidence`;
- `logs`;
- `ide` (opt-in only); and
- `all-regenerable`.

Suggested package scripts:

```text
npm run repo:hygiene
npm run repo:hygiene:check
```

The implementation must not wrap `git clean -fdX`.

## 12. Safety and reproducibility improvements

### `ROOT-HYGIENE-012` — environment templates

Add a tracked root `.env.example` containing placeholder/documentation for
`RAZORPAY_KEY_ID` without a real value. Because `.gitignore` currently ignores
`.env.*`, add the narrow `!.env.example` exception.

Keep App Check debug tokens in ignored `.env.local`; do not provide a realistic
token placeholder that could be mistaken for a credential.

### `ROOT-HYGIENE-013` — Firebase production-default safety

Current state (verified 2026-07-12):

- `.firebaserc` maps `default` to the production project.
- `tool/firebase_with_env.sh` safely requires `dev|staging|prod` and passes an
  explicit Firebase project.
- CI is already wrapper-gated: hosting deploys run
  `tool/firebase_with_env.sh prod`, functions/rules deploys run
  `tool/deploy_firebase_targets.sh <env>`, and emulator runs pin
  `--project demo-catch-rules`. The remaining exposure is local and
  interactive only.
- `functions/package.json` still exposes `firebase deploy --only functions`
  and `firebase functions:log` without an explicit environment; both ride the
  `default` alias.

Recommended default:

1. map `default` to the dev project or remove reliance on `default`;
2. route the Functions `deploy` **and** `logs` scripts through the
   environment wrapper — after the alias flip, a raw `logs` would silently
   read dev logs during a production incident;
3. fail raw production deploy attempts without an explicit environment and
   non-interactive/reviewer contract;
4. add tests proving the wrapper resolves each alias correctly and rejects an
   unsupported/missing environment; and
5. document the expected failure mode: hosting targets are mapped only for
   the production project, so a raw `firebase deploy` under a dev `default`
   fails on unmapped targets — fail-safe, but it will surprise whoever hits
   it first.

Keep this change in a separate review unit from cache deletion because it
affects release behavior.

### `ROOT-HYGIENE-014` — minor conventional root support

Recommended low-risk additions/cleanup:

- add `android/.kotlin/` to the relevant ignore policy;
- delete `devtools_options.yaml` if it remains empty and unowned;
- add a small `.editorconfig` for final newline, charset, and baseline
  whitespace behavior across Dart, TypeScript, JSON, YAML, Markdown, and shell;
- avoid adding `.vscode/`, `.idea/`, `CONTRIBUTING.md`, or another root doc
  unless a real shared workflow requires it; and
- add a single toolchain-version contract (Flutter, Node, Firebase CLI,
  CocoaPods) that CI reads or is checked against, as a firm Phase 5 item.
  (Fable upgraded this from "consider only if drifting" during review:
  waiting for demonstrated drift means paying the debugging cost first, and
  a version contract is exactly the compounding-system category this effort
  exists to build.)

## 13. Implementation sequence and PR slicing

### Phase 0 — review and freeze

- Fable records §14 dispositions. (Done 2026-07-12; owner rows remain.)
- Triage any live worktrees under `/private/tmp` — verify clean/pushed, then
  relocate or remove — before OS temp cleanup races them.
- Owner confirms no build/emulator/Storybook process must stay alive.
- Owner confirms whether April release logs or the host-page concept have
  historical value.
- Re-run the evidence snapshot; do not rely on the figures in §2.

### Phase 1 — local housekeeping (no source commit)

- Produce the exact dry-run report.
- Review protected exclusions and worktree status.
- Clean approved regenerable scopes.
- Record before/after bytes and any skipped path.
- Prune missing worktree metadata; remove real worktrees only after separate
  confirmation.

### Phase 2 — tracked legacy/artifact cleanup

- Retire `codex_audit/` per the accepted disposition.
- Delete or migrate `artifacts/host-page-render/`.
- Add `artifacts/README.md` and explicit subpath policies.
- Keep active marketing screenshots and `design_context_pack/` intact.

### Phase 3 — root documentation cleanup

- Make `CLAUDE.md` route through `AGENTS.md`.
- Reduce overlapping `README.md` and `PROJECT_CONTEXT.md` content only after
  current detail is owned elsewhere.
- Replace machine-specific links.
- Repair `TESTS.md` around the generated inventory.
- Treat the `PROJECT_CONTEXT.md` work as one pass: shorten, replace links,
  and repair the staleness flagged by the 2026-06-18 architecture audit
  together, then re-run `node tool/agent/check_agent_readiness.mjs` — agent
  context quality is on the delegation critical path, so this phase has more
  leverage than its "documentation cleanup" label suggests.
- Update docs index, doc versions, summaries, and audit receipt.

### Phase 4 — enforcement tooling

- Add root manifest/schema.
- Add scanner, fixture tests, manifest registration, and CI wiring.
- Add the dry-run-first cleaner and protected-path tests.
- Add npm scripts and `tool/README.md` routing.
- Add a regression-ledger entry for root-residue recurrence.

### Phase 5 — deploy safety and small conventions

- Apply the accepted Firebase default/wrapper decision in an isolated commit.
- Add `.env.example` and its ignore exception.
- Add `.editorconfig` if accepted.
- Add the toolchain-version contract and a CI-pin consistency check.
- Remove/configure `devtools_options.yaml` and add `.kotlin/` ignore coverage.

### Recommended review units

1. **Local-only cleanup receipt:** no commit.
2. **Artifact retirement and ownership:** tracked deletions plus
   `artifacts/README.md`.
3. **Root docs and portable links:** documentation-only.
4. **Root manifest/scanner/cleaner:** tooling, tests, manifest, CI.
5. **Firebase/environment safety:** separately reviewable release/config change.

Do not combine all phases into one large patch.

## 14. Fable and owner decision ledger

Fable recorded its dispositions on 2026-07-12 (spec v0.2.0). Every `change`
row has its replacement direction folded into the referenced section. The
repository owner closed the remaining decisions on 2026-07-19.

| Decision id | Question | Recommended default | Disposition |
|---|---|---|---|
| `FABLE-ROOT-001` | Is the two-track model—local cleanup plus tracked governance—correct? | Accept. | `accept` (Fable 2026-07-12) |
| `FABLE-ROOT-002` | May `codex_audit/` be deleted after owner confirmation? | Delete it; do not create another archive folder. | `closed` — path is absent and prohibited by the root manifest; no archive replacement |
| `FABLE-ROOT-003` | Does `artifacts/host-page-render/` retain active design value? | Delete; if valuable, migrate only selected references with a historical label. | `accept` (Fable) — zero references verified outside this spec; delete without migration |
| `FABLE-ROOT-004` | Should `design_context_pack/` remain a tracked root deliverable? | Keep in place for this tranche. | `accept` (Fable) |
| `FABLE-ROOT-005` | Is the proposed tracked/generated artifact split and 14-day capture retention appropriate? | Accept as initial local default; CI should not enforce local size/age. | `change` (Fable) — add the retention executor and repo-wide evidence lanes in §9, else the policy is ceremonial |
| `FABLE-ROOT-006` | May root docs be shortened to the ownership map in §10? | Accept, provided content migrates before deletion and no new parallel docs appear. | `accept` (Fable) — with the Phase 3 one-pass sequencing (shorten + links + staleness, then re-run agent readiness) |
| `FABLE-ROOT-007` | Should portable-link violations be blocking? | Yes, for tracked Markdown links. | `accept` (Fable) — block after Phase 3 fixes the 127 baseline violations |
| `FABLE-ROOT-008` | Should test inventory become generated and Git-backed? | Yes. | `accept` (Fable) — the 217-vs-222 gap was reverified; follow the existing generate/`--check` idiom (`design:widgets`) rather than inventing a new pattern |
| `FABLE-ROOT-009` | Is a manifest-backed, dry-run-first cleanup tool the right prevention mechanism? | Yes; never use broad `git clean`. | `accept` (Fable) |
| `FABLE-ROOT-010` | Should the Firebase default become dev and raw deploys be wrapper-gated? | Yes; review separately as release behavior. | `change` (Fable) — direction right, framing corrected: CI is already wrapper-gated, so scope is local scripts; include the `logs`-script and hosting-target side effects now in §12 |
| `FABLE-ROOT-011` | Should `.env.example`, `.editorconfig`, `.kotlin/` ignore, and empty DevTools cleanup proceed? | Accept all four unless a DevTools extension owner is identified. | `accept` (Fable) — `devtools_options.yaml` confirmed empty; toolchain-version contract additionally promoted to a firm Phase 5 item |
| `FABLE-ROOT-012` | Are any other root files/folders intentionally missing from this spec? | Add them before implementation; unknown root entries must not be silently grandfathered. | `change` (Fable) — added: worktree placement policy (§7), repo-wide evidence lanes (§9), extra dynamic patterns and the `catch-dating-app/` prohibition (§11); see `FABLE-ROOT-013`/`014` |
| `FABLE-ROOT-013` | Should worktrees be required to live in a durable location (never `/private/tmp`), with the prunable-registration count reported locally? | Yes; adopt the placement policy in `ROOT-HYGIENE-002`. | `closed` — canonical local location is ignored `.claude/worktrees/` |
| `FABLE-ROOT-014` | Should shared agent assets (`.claude/settings.json`, shared skills) become tracked via narrow `.gitignore` negations as the team/agent count grows? | Decide deliberately; today's default is machine-local. | `closed` — remain machine-local until an explicit team distribution requirement exists |

### Recorded Fable responses (2026-07-12)

```text
FABLE-ROOT-001: accept
Notes: Matches the repo's existing enforcement culture (tools manifest,
vacuity proofs, audit registry).

FABLE-ROOT-002: accept
Notes: Contents verified; Git history + passes.jsonl suffice. No archive
folder. Owner still confirms the ignored logs/zip deletion.

FABLE-ROOT-003: accept
Notes: Verified zero references outside this spec (grep across md/json/mjs/
ts/tsx/yml); the website copy deck does not use it.

FABLE-ROOT-004: accept
Notes: CI-checked, manifested, consumed. Leave in place.

FABLE-ROOT-005: change
Notes: Split and 14-day default accepted, but add an executor (dry-run
report prints violations) and cover the four non-artifacts evidence lanes.

FABLE-ROOT-006: accept
Notes: One pass for PROJECT_CONTEXT.md (shorten + links + 2026-06-18 audit
staleness), then re-run agent readiness.

FABLE-ROOT-007: accept
Notes: Zero tracked-but-ignored files exist, and links are fixed in Phase 3,
so the check can block immediately after.

FABLE-ROOT-008: accept
Notes: 217 vs 222 confirmed by re-measurement. Reuse the generate/--check
idiom already established by design:widgets.

FABLE-ROOT-009: accept
Notes: Manifest-backed dry-run cleaner; never git clean -fdX.

FABLE-ROOT-010: change
Notes: CI already routes through firebase_with_env.sh /
deploy_firebase_targets.sh with the rules-emulator project pinned. Scope the
fix to local scripts; wrap `logs` too; document the unmapped-hosting-target
failure mode.

FABLE-ROOT-011: accept
Notes: All four proceed. Version contract upgraded from "consider" to firm
Phase 5 (see ROOT-HYGIENE-014).

FABLE-ROOT-012: change
Notes: Additions recorded — worktree placement policy, evidence lanes,
dynamic patterns (firebase-export-*/, emulator-data/, firestore-debug.log,
*.iml), catch-dating-app/ prohibition, shared owner-slug vocabulary.

FABLE-ROOT-013: accept (pending-owner: location)
Notes: Root cause of all 30 dead registrations is /private/tmp placement;
macOS purges it. Durable-location policy required.

FABLE-ROOT-014: pending-owner
Notes: .claude/ is wholly gitignored today, so skills/settings are
machine-local. Right for now; becomes a velocity question as more people
and agents work the repo. Deliberate decision, not a silent default.
```

## 15. Acceptance criteria

### Local housekeeping

- Before/after disk usage is recorded.
- At least the approved regenerable scopes are removed or explicitly skipped
  with reasons.
- No tracked file, environment value, signing asset, active worktree, or IDE
  configuration outside the selected scope is removed.
- Git remains healthy and the working tree contains only the intended tracked
  implementation changes.

### Tracked root state

- Every top-level entry matches exactly one manifest classification.
- `codex_audit/`, `.audit_work/`, root Flutter logs, and other retired names
  cannot recur without a scanner failure.
- `artifacts/` has an explicit tracked/generated/retention contract.
- Active curated marketing media and `design_context_pack/` still pass their
  existing checks.
- Root docs have zero machine-specific Markdown-link violations.
- Test inventory excludes dependencies/generated output and is reproducible.
- Firebase deploy commands require an explicit accepted environment policy.

### Tooling proof

- Root hygiene scanner unit tests include known-good and known-bad fixtures.
- Cleaner tests prove every protected path survives every applicable scope.
- Tool-manifest vacuity and enforcement-integrity checks pass.
- The new root scanner is cheap enough to run on every PR.
- The cleanup command defaults to dry-run and requires explicit mutation flags.

### Required final commands

The implementing pass should adapt the exact focused commands to the accepted
scope, but at minimum run:

```sh
node tool/run.mjs check --manifest-only
node tool/run.mjs check --category meta
node tool/run.mjs check --category agent
node tool/check_repository_root_hygiene.mjs
node --test tool/check_repository_root_hygiene.test.mjs
node tool/repository_hygiene.mjs --json
node tool/agent/check_agent_readiness.mjs
dart tool/audit_registry.dart refresh
dart tool/audit_registry.dart report
git diff --check
```

Any path/filename changes made during implementation must update these proposed
commands rather than leaving stale instructions in the spec.

## 16. Risks and mitigations

| Risk | Mitigation |
|---|---|
| Deleting an active build product causes confusing failures | Stop active processes, dry-run, then clean exact manifest paths; document regeneration commands. |
| Losing credentials or signing state | Hard-code protected-path tests; never infer safety from Git ignore status. |
| Removing an active worktree | Report only; require Git status and explicit human confirmation; use `git worktree remove`. |
| Deleting design evidence Fable still needs | Resolve `FABLE-ROOT-002` and `FABLE-ROOT-003` before tracked deletion. |
| Moving `design_context_pack/` breaks consumers | Keep it in place; any relocation is a separate all-consumer migration. |
| Documentation gets shorter but less useful | Migrate current material to existing owner docs before deleting duplicate sections. |
| Root manifest becomes a ceremonial allowlist | Require owner, kind, tracking, cleanup, protection, and known-bad scanner tests. |
| Local size thresholds destabilize CI | Report size/age locally; CI gates only deterministic classification and tracking rules. |
| Raw Firebase commands still reach production | Make environment explicit, wrapper-gate deploy scripts, and test alias resolution. |
| Generated output returns immediately | Treat cleanup as maintenance, while scanners prevent unowned root residue and local reporting exposes growth. |
| Worktrees created under the OS temp root are purged and leave stale metadata | Placement policy in `ROOT-HYGIENE-002` (durable location, never `/private/tmp`), local prunable-count reporting, Phase 0 triage of live `/tmp` worktrees. |
| Retention thresholds exist but nothing runs them | Dry-run default prints retention violations; local readiness reporting surfaces the count (§9). |

## 17. Rollback and recovery

- Tracked deletions are recoverable from Git until history is rewritten; use
  normal revert commits, not destructive resets.
- Generated caches recover through their documented package/build commands.
- If a cleanup scope causes a tool failure, restore by running that scope's
  declared recovery command and tighten the manifest before rerunning cleanup.
- Environment/signing/worktree state has no automated rollback and therefore
  remains outside automatic cleanup.
- If a Fable-approved historical artifact later proves necessary, restore only
  that artifact to its correct owner with a manifest/consumer, not the retired
  miscellaneous folder.

## 18. Completion and lifecycle

Implementation closed on 2026-07-19. The owner accepted `.claude/worktrees/` as
the durable worktree location, retained shared `.claude` assets as machine-local
until a team distribution need exists, and confirmed that the already-absent
`codex_audit/` must remain prohibited rather than be recreated. Permanent
policy now lives in the owner docs, root manifest, executable checks, generated
test inventory, and audit registry.

The historical closeout sequence was:

1. append the accepted dispositions to §14;
2. bump the spec version;
3. execute the phases as separate review units;
4. keep unresolved decisions explicitly pending/deferred;
5. record implementation proof in the audit registry; and
6. when all accepted work is complete, migrate permanent policy to
   `tool/README.md`, `docs/agent_operating_model.md`, `artifacts/README.md`,
   the root manifest, and relevant release/docs owners, then mark this spec
   implemented or archive/delete it according to docs hygiene policy.

The spec must not become a permanent second source of truth after its policies
have moved into enforcement and owner docs.
