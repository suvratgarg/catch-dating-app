# Codex Audit Index

Last updated: 2026-05-01

This directory keeps audit evidence and historical trackers. Current project
setup should be read from the canonical docs first, then from the historical
audit notes only when you need evidence for how a decision was reached.

## Current Sources Of Truth

| Topic | Current doc |
| --- | --- |
| Product, architecture, data model, routes, gotchas | [`PROJECT_CONTEXT.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/PROJECT_CONTEXT.md) |
| Local setup and common commands | [`README.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/README.md) |
| Firebase environment workflow | [`firebase/README.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/firebase/README.md) |
| Verified Firebase/App Check/Functions state | [`firebase_environment_current_state.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/firebase_environment_current_state.md) |
| Cloud Functions security/secrets/deploy runbook | [`functions/README.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/functions/README.md) |
| Test-suite inventory | [`TESTS.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/TESTS.md) |
| Release backlog | [`production_release_checklist.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/production_release_checklist.md) |
| Current release/setup/build/distribution verdict | [`release_setup_2026-04-30/current_release_setup_audit.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/release_setup_2026-04-30/current_release_setup_audit.md) |

The current release/setup tracker is the source of truth for cross-platform
builds, Firebase/App Check, Firestore setup, Xcode/Gradle toolchain state,
Apple signing, Developer ID notarization, and remaining setup caveats.

## Current Audit Docs

| File | Status | Use it for |
| --- | --- | --- |
| [`firebase_environment_current_state.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/firebase_environment_current_state.md) | Current | Firebase project/app/App Check/Functions state. |
| [`release_setup_2026-04-30/current_release_setup_audit.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/release_setup_2026-04-30/current_release_setup_audit.md) | Current source of truth | Build, signing, distribution, Firebase/Firestore, Apple account, Xcode/Gradle, notarization, trust verification, and setup readiness verdict. |
| [`production_release_checklist.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/production_release_checklist.md) | Current backlog | Release readiness work that still needs product/account/store decisions. |
| [`design_handoff_ui_fidelity_audit.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/design_handoff_ui_fidelity_audit.md) | Current UI audit snapshot | Design-handoff fidelity, implemented screen groups, and remaining UI gaps. |
| [`lib_feature_completeness_matrix.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/lib_feature_completeness_matrix.md) | Current feature map | Folder-level completion status and product gaps. |
| [`safety_blocking_account_deletion_plan.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/safety_blocking_account_deletion_plan.md) | Current safety plan with implementation notes | Blocking, reporting, and account deletion intent/history. |
| [`ios_release_readiness_audit_2026-04-30.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/ios_release_readiness_audit_2026-04-30.md) | Recent iOS evidence | iOS signing/runtime findings and device verification notes. |

## Historical Evidence

These files are historical snapshots. They may include statements that were true
when written but have since been superseded by the current docs above.

| File | Superseded by |
| --- | --- |
| [`firebase_console_audit.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/firebase_console_audit.md) | `firebase_environment_current_state.md`, `firebase/README.md` |
| [`remaining_config_resolution_tracker_2026-04-29.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/remaining_config_resolution_tracker_2026-04-29.md) | `firebase_environment_current_state.md`, `production_release_checklist.md`, active release tracker |
| [`build_readiness_dependency_report_2026-04-29.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/build_readiness_dependency_report_2026-04-29.md) | Active release tracker and current release checklist |
| [`target_build_audit_2026-04-28.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/target_build_audit_2026-04-28.md) | Newer build/readiness docs and active release tracker |
| [`archive/root_trackers/`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/archive/root_trackers/) | `PROJECT_CONTEXT.md`, `TESTS.md`, and this index |

## Archive Contents

`archive/root_trackers/` contains old root-level trackers that are complete or
stale:

- `CLAUDE_audit_todo_tracker.md`
- `auth_review_tracker.md`
- `onboarding_audit_tracker.md`
- `runs_review_tracker.md`
- `run_clubs_review_tracker.md`

Keep these for provenance when needed. Do not use them as the current status of
auth, onboarding, runs, run clubs, or tests.
