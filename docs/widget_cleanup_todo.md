---
doc_id: widget_cleanup
version: 2.3.0
updated: 2026-05-06
owner: recursive_audit_loop
status: active
---

# Widget Cleanup To-Do

This file is now the human-readable entry point for widget cleanup. The active
machine-readable state lives in `docs/audit_registry/backlog.json`; recurring
rules live in `docs/audit_registry/rules.json`; full historical notes are
archived at `docs/audit_registry/archive/widget_cleanup_todo_2026_05_05_full.md`.

## Read Policy

For future passes:

1. Read `docs/audit_registry/README.md`.
2. Read `docs/audit_registry/backlog.json` for current pending work and scanner
   counts.
3. Read `docs/audit_registry/rules.json` for active/watch rules.
4. Read feature-specific sections in `docs/widget_catalog.md` only when the
   target surface needs widget inventory.
5. If the pass adds, deletes, moves, renames, or materially changes a widget,
   primitive API, screen ownership model, sliver/tab structure, or reusable
   design-system role, update `docs/widget_catalog.md` in the same pass.
6. Search the archived full tracker only when a stable debt id, rule id, or
   old finding points there.

## Rule Changelog

### 2.3.0

- Added `STREAM-LIFECYCLE-QUEUE` after the dashboard booked-runs listener bug.
  Future stream passes should classify each listener as global, route-owned,
  prewarmed keepAlive, or retained-tab gated instead of applying one lifecycle
  rule everywhere.
- Added `ERROR-UI-QUEUE`. The app has a branded framework-crash fallback, but
  still needs a canonical app-facing error primitive for full-screen, sliver,
  and inline data-load failures.

### 2.2.0

- Reconciled doc-hygiene metadata after the widget-catalog rule was added.
- `docs/README.md`, `doc_versions.json`, and `doc_summaries.json` now identify
  `docs/audit_registry/rules.json` as the active owner for recurring audit
  rules.

### 2.1.0

- Moved active backlog, scanner counts, and next-up ordering into
  `docs/audit_registry/backlog.json`.
- Moved recurring anti-patterns into `docs/audit_registry/rules.json`.
- Added `WIDGET-CATALOG-001` as an active rule so widget architecture changes
  update `docs/widget_catalog.md` instead of leaving inventory drift.
- Archived the previous long tracker at
  `docs/audit_registry/archive/widget_cleanup_todo_2026_05_05_full.md`.

### 2.0.0

- Introduced versioned recursive audit rules, pass receipts, doc read policies,
  and physical-phone debug-loop evidence.

## Current Status

Use `dart tool/audit_registry.dart backlog` for the current machine-readable
status. Snapshot as of 2026-05-05:

| Debt | Status | Next action |
|---|---|---|
| `STREAM-LIFECYCLE-QUEUE` | active | Audit retained indexed-stack tab branches and screen-backed realtime streams. No remaining Firestore listener timeout was found in `lib`, but stream ownership still needs a cost/lifecycle pass across Clubs, Chats, Catches, Profile, payments, safety, and detail routes. |
| `ERROR-UI-QUEUE` | active | Build/migrate to branded app error surfaces. `CatchFrameworkErrorView` handles Flutter framework crashes only; data-load errors still use fragmented raw text, `CatchErrorText`, local cards, and `CatchEmptyState` variants. |
| `PROFILE-001` | blocked | Null-profile blank branch fixed and profile route migrated to one sliver-native `CustomScrollView` with a pinned Profile/Preview row; physical-device verification is blocked until the iPhone is connected/detectable. Inspect provider data and preview constraints if the body is still blank on-device. |
| `SPACING-001` | completed | Canonical 4-point `Sizes.p*` presentation/widget candidates are fully migrated to `CatchSpacing.s*`; fine-grained compatibility helpers stay watch-only. |
| `DOC-HYGIENE-QUEUE` | active | Keep docs index, doc versions, doc summaries, and registry state synchronized. |

## Scanner Snapshot

Source of truth: `docs/audit_registry/backlog.json`.

| Category | Count | Note |
|---|---:|---|
| Centralized widget timing | 1 | Intentional `pumpFeatureUi` helper. |
| Async unit flushes | 0 | Clean after `flushTestEventQueue` migration. |
| Positional widget finders | 0 | Clean. |
| Presentation repository reaches | 0 | Clean. |
| `CatchTokens` prop drilling | 0 | Clean. |
| Feature tappable candidates | 0 | Scanner skips labeled/tooltipped/semantic controls. |
| Legacy 4-point spacing candidates | 0 | Clean. |
| Fine-grained spacing compatibility | 21 | Keep unless the component itself is being redesigned. |
| Presentation plugin imports | 0 | Clean. |

## Completion Rule

Every widget cleanup pass must finish by stamping touched files and proof in the
audit registry:

```sh
dart tool/audit_registry.dart mark-pass \
  --pass <pass-id> \
  --rules <RULE-ID[,RULE-ID]> \
  --paths <comma-separated paths> \
  --proof "flutter test ..." \
  --proof "flutter analyze --no-fatal-infos ..."
```
