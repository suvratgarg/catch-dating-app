---
doc_id: widget_cleanup
version: 2.3.21
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

### 2.3.21

- Added `docs/backend_operation_catalog.md` as the human-readable map of
  direct client writes, callable-owned mutations, trigger-owned projections,
  server-only collections, and notification starting points.
- Functions audit found and fixed two contract issues: `tool/firestore_contract.json`
  now includes `firstName`, `lastName`, and `displayName`, and account deletion
  now clears retained `firstName`, `lastName`, and `displayName` fields.
- Added `FUNCTIONS-RATE-LIMIT-001` to the backlog for callables whose shared
  rate-limit configuration is not yet applied at the handler.
- Added `NOTIFICATIONS-QUEUE` so notification/activity timeline work starts
  from an explicit backend-owned fan-out design instead of ad hoc client writes.

### 2.3.20

- Added `docs/ui_layout_spacing.md` as the durable owner for shared screen
  padding, tab body insets, sliver body gaps, and card/photo spacing contracts.
  The current Profile tab body inset is now documented as 20 px left/right, 8
  px top, and 32 px bottom.
- Reopened `PROFILE-001` from device-confirmation state to active bug state:
  physical testing still shows Profile Preview does not continuously restore
  the outer Profile header when dragging upward/downward from the top of the
  internal preview card unless the gesture starts near the tab row. This is
  documented but intentionally deferred while doc hygiene, stream lifecycle,
  and error UI watch queues are audited.
- Stream lifecycle watch audit found no Firestore listener timeout regression.
  The only remaining `.timeout` matches are one-shot auth/payment protocol
  callbacks, not snapshot streams.
- Error UI watch audit found no `CatchErrorText` regression and the scanner
  still reports zero raw app-facing error surface candidates. Remaining
  `"Unable to load..."` / `"Something went wrong"` matches are branded
  primitive copy, mappers, framework fallback, or tests.

### 2.3.19

- Closed the low-hanging `PROFILE-CARD-POLISH-001` implementation items:
  removed the redundant lower `ProfileRunningSection`, retained one canonical
  dark `RUN PROFILE` card, and inset/rounded all non-hero photos inside the
  shared Swipes/Profile Preview/Public Profile card path. Remaining work is
  visual device review and any product-driven refinements after inspection.

### 2.3.18

- Added full-screen celebration moments for host run creation, user run signup,
  paid run confirmation, participant self-check-in, and matches. These now
  share `CatchCelebrationScreen` and `CelebrationEffectsController`, with
  haptics on by default. Host attendance intentionally remains an operational
  attendance flow without a celebration. Sound is deferred under
  `CELEBRATION-SOUND-001` and should be routed through the effects controller
  when implemented.
- Added `RunCheckInLocationService` so self-check-in location lookup is
  injectable in tests instead of invoking Geolocator directly from the
  controller.

### 2.3.17

- Refactored Home into a Profile-style two-tab surface. `DashboardScreen` now
  owns the route-local tab controller, `NestedScrollView`, collapsible Home
  header, pinned `Dashboard`/`Activity` tab row, and native horizontal tab
  swiping. The Dashboard tab keeps the existing dashboard widgets as sliver
  bodies, while the Activity tab owns notifications and updates in a
  timeline-style feed. Activity is no longer duplicated inside Dashboard
  content.

### 2.3.16

- Added concrete follow-up items for `PROFILE-CARD-POLISH-001` after visual
  review. Retain a single `RUN PROFILE` summary card as the canonical running
  identity section, remove the redundant lower `RUNNING` pace/distance chip
  section unless it has non-duplicative content, keep all profile-card sections
  on the dark `ProfileCardPalette`, and make inline/additional photos look
  placed inside the card with consistent inset, rounded corners, and spacing.

### 2.3.15

- Started the shared profile-card polish queue. The public-facing dating card
  used by Swipes, Profile Preview, and Public Profile now keeps one identical
  rendering path, remains dark/immersive while adapting to light and dark app
  themes, shows display name + age + optional city on the hero, moves
  relationship goal into detail chips, promotes the bio prompt before running
  stats, and replaces the flat missing-photo block with a branded fallback.

### 2.3.14

- Added editable Profile `Display name` as the public profile name field. New
  profiles initialize it from onboarding first name; edit profile validates it
  as required/non-blank and saves trimmed values through
  `ProfileEditController`; public profile projection now prefers it before
  falling back to first name or legacy full name.
- Tightened the data-contract loop for this field: Dart model, generated
  Freezed/json, generated Functions Firestore interface, callable validation,
  Firestore create rules, rules fixtures, and profile/onboarding tests were
  updated in the same pass.

### 2.3.13

- Removed visible tick marks from Profile range edit sliders. Age and pace
  range sheets still use discrete divisions for valid saved values, but the
  track now appears continuous instead of broken/dotted.

### 2.3.12

- Fixed Profile Preview scroll coordination. The shared profile card remains
  independently scrollable, but its leading overscroll is now bridged to the
  route-owned outer `NestedScrollView` so dragging down from the top of the
  preview card continuously restores the Profile header instead of requiring a
  drag from the tab row.

### 2.3.11

- Standardized Profile tab body insets. Edit and Preview now share
  `profileTabBodyPadding` with 20 px horizontal, 8 px top, and 32 px bottom.
  Future tabbed sliver passes should use one named inset per sibling tab group
  and place persistent visible gaps inside independently scrollable filled
  children.

### 2.3.10

- Fixed the Profile preview top-gap regression. The preview card inset now
  lives inside the filled tab body instead of in outer sliver padding, so the
  visible padding under the pinned tab row comes back when the card is scrolled
  back to its own top.

### 2.3.9

- Profile tab labels now use `Edit` and `Preview` instead of repeating
  `profile` inside the tabs, since the route title already establishes the
  Profile context.

### 2.3.8

- Added a multi-select chip affordance to the shared `ChipField<T>` primitive:
  selected chips in multi-select sheets now render a leading check icon. This
  keeps single-select sheets visually stable while making fields such as
  Interested in, Languages, Preferred distances, and Running reasons clearer.

### 2.3.7

- Closed the automated Profile `NestedScrollView` overlap validation pass. The
  Profile title sliver now scrolls away normally, the pinned Edit/Preview tab
  row is the only absorbed overlap obstruction, each tab body injects that
  overlap before rendering content, and widget coverage verifies the
  absorber/injector structure plus body placement below the pinned tab row.
  Remaining Profile work is physical-device visual confirmation.

### 2.3.6

- Reopened the Profile nullable single-choice issue with root-cause tests
  instead of relying on the earlier narrow coverage. All nullable single-choice
  fields now have no-selected-chip coverage when empty, domain decode preserves
  omitted optional enum fields as null, `ChipField` has a direct empty
  single-select rendering test, and immediate-save single-choice sheets show a
  visible saving state. Failed single-choice saves clear the optimistic pending
  chip highlight and keep the sheet open with inline error feedback.

### 2.3.5

- Moved `STREAM-LIFECYCLE-QUEUE` to watch. Firestore realtime listeners no
  longer use idle timeouts, retained tab roots are gated while inactive, and
  route-owned streams for run detail, chat messages, match detail, payment
  history, and blocked users have focused auto-dispose tests. The only
  remaining `.timeout` usage in `lib` is for one-shot auth/payment protocol
  callbacks, not Firestore snapshot listeners.

### 2.3.4

- Completed the first stream lifecycle batch. `AppShell` no longer prewarms the
  Clubs list stream; `AppShellActiveTab` moved to a small shared lifecycle file;
  Clubs, Catches, Chats, and Profile tab roots now render inert shells while
  inactive; and run-club Firestore stream families are auto-dispose again.
  Retained tabs should only keep streams open while inactive when there is an
  explicit shell-wide or UX reason.

### 2.3.3

- Hard-migrated away from `CatchErrorText` instead of retaining it as a
  compatibility layer. Remaining app-facing load failure branches now call
  `CatchErrorState`, `CatchErrorScaffold`, or `CatchInlineErrorState` directly
  with feature context and retry callbacks where practical. The raw error
  surface scanner now reports zero candidates.

### 2.3.2

- Started `ERROR-UI-QUEUE`: added branded full-screen/sliver/inline app error
  primitives and migrated first-batch critical tabs. The scanner now reports
  remaining raw error-surface candidates for follow-up batches.

### 2.3.1

- Completed the profile edit mutation UX pass: text, height, single-choice,
  multi-choice, and range edit sheets now save before dismissing, show
  pending/error feedback, and keep optional single-choice fields visually empty
  when no value is stored.

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
status. Snapshot as of 2026-05-06:

| Debt | Status | Next action |
|---|---|---|
| `PROFILE-CARD-POLISH-001` | needs_device_confirmation | Shared Swipes/Profile Preview/Public Profile card now uses one canonical dark `RUN PROFILE` section and inset/rounded non-hero photos. Device visual review is deferred by user request. |
| `PROFILE-001` | active | Sliver/rendering is not complete: Profile Preview still does not continuously restore the outer header from the preview-card top gesture on device. Defer implementation until after doc hygiene / stream lifecycle / error UI queue pass. |
| `CELEBRATION-SOUND-001` | identified | Haptics are live for full-screen celebration moments. Add optional sound later through `CelebrationEffectsController`, with mute/silent-mode/accessibility respect and tests using an injected fake effects controller. |
| `STREAM-LIFECYCLE-QUEUE` | watch | Known Firestore listener lifecycle issues are resolved. Keep the rule active as a guardrail: new realtime streams should be auto-dispose, retained-tab gated, or explicitly documented as shell/global. |
| `ERROR-UI-QUEUE` | watch | Branded error primitives are in place, `CatchErrorText` is deleted, and the raw error-surface scanner is clean. Keep watching for regressions and add typed catalogue entries only when repeated product/domain failures need branching, analytics, retry policy, or tests. |
| `PROFILE-FIELD-PARITY-001` | watch | Shared validators and profile edit mutation UX are aligned. Nullable single-choice sheets now have root-cause coverage across all optional fields and visible immediate-save pending feedback. Keep onboarding intentionally low-friction unless product accepts the signup cost of adding more optional fields. |
| `PROFILE-001` | needs_device_confirmation | Profile currently uses `NestedScrollView` with native `TabBarView` paging. The stale single-`CustomScrollView` registry text has been corrected. Automated coverage now validates the `NestedScrollView` absorber/injector contract and body placement under the pinned tab row; remaining work is physical-device visual confirmation. |
| `SPACING-001` | completed | Canonical 4-point `Sizes.p*` presentation/widget candidates are fully migrated to `CatchSpacing.s*`; fine-grained compatibility helpers stay watch-only. |
| `DOC-HYGIENE-QUEUE` | active | Keep docs index, doc versions, doc summaries, and registry state synchronized. |

## Scanner Snapshot

Source of truth: `docs/audit_registry/backlog.json`.

| Category | Count | Note |
|---|---:|---|
| Centralized widget timing | 3 | Intentional `pumpFeatureUi` helper plus two calendar timing pumps queued for a later testability pass. |
| Async unit flushes | 0 | Clean after `flushTestEventQueue` migration. |
| Positional widget finders | 0 | Clean. |
| Presentation repository reaches | 0 | Clean. |
| `CatchTokens` prop drilling | 0 | Clean. |
| Feature tappable candidates | 0 | Scanner skips labeled/tooltipped/semantic controls. |
| Legacy 4-point spacing candidates | 0 | Clean. |
| Fine-grained spacing compatibility | 19 | Keep unless the component itself is being redesigned. |
| Presentation plugin imports | 0 | Clean. |
| Raw app-facing error surface candidates | 0 | Clean after the hard `CatchErrorText` removal and direct primitive migration. |

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
