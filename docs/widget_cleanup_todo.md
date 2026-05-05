---
doc_id: widget_cleanup
version: 2.1.0
updated: 2026-05-05
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
5. Search the archived full tracker only when a stable debt id, rule id, or
   old finding points there.

## Rule Changelog

### 2.1.0

- Moved active backlog, scanner counts, and next-up ordering into
  `docs/audit_registry/backlog.json`.
- Moved recurring anti-patterns into `docs/audit_registry/rules.json`.
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
| `SPACING-001` | pending | Migrate legacy `Sizes.p*` to `CatchSpacing.s*` piecemeal in touched surfaces. |
| `PROFILE-001` | deferred | Fix profile tab/preview blank rendering when the user asks to return to profile. |
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
| Legacy spacing matches | 139 | Piecemeal migration only. |
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
