---
doc_id: widget_cleanup
version: 2.3.45
updated: 2026-05-08
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

### 2.3.45

- Closed `DASHBOARD-RUN-HYPE-THUMBNAILS-001`: Dashboard upcoming-run cards and
  Run detail now share `RunHypeAvatarStack`, which uses blurred
  `photoThumbnailUrls` selected from recent matching `runParticipations`.
  `PersonAvatarStack` is the reusable primitive for overlapping avatars, and
  chat/match surfaces consume thumbnail URLs without the blurred treatment.
- Added backend profile-photo thumbnail generation plus a dry-run/apply
  backfill script. Existing beta data needs `npm run
  backfill:profile-thumbnails -- --apply` with `FIREBASE_STORAGE_BUCKET` set
  after deploy/credentials are available.
- Chat image picking/uploading now goes through `ImageUploadRepository` so
  profile, onboarding, run-club cover, and chat media all use centralized
  picker resize/compression policies.

### 2.3.44

- Run maps should share `RunPinsMap` rather than creating independent
  `FlutterMap` stacks. Browse maps center on device location first, the
  selected run-club city second, and run pins only as a last fallback. Keep
  address-only runs in list/sheet UI but omit map pins until coordinates are
  present.

### 2.3.43

- Run detail location affordances must reflect data capability: show a chevron
  and map navigation only when a run has exact starting coordinates. Address-
  only runs should keep the location card static so users do not enter an
  empty or approximate map.

### 2.3.40

- Chat message rows are variable-height content. Avoid `prototypeItem`,
  `itemExtent`, or fixed row heights in `ChatMessageList`; otherwise multi-line
  bubbles and image messages can clip or overlap timestamps and neighboring
  rows.

### 2.3.39

- Chat inbox rows are one row per matched person, not one row per match
  document when legacy/duplicate match docs exist. Collapse duplicates in
  `ChatsListViewModel`, keep the latest preview/timestamp, and aggregate the
  visible unread count for the current user.
- Do not label chat counts as `active` without a real presence or activity
  signal in the data model. Use match/person count copy until presence exists.
- Avoid redundant list headers in tab roots. The Chats tab already has a
  screen title, so the conversations list should not add a second `Messages`
  header.

### 2.3.38

- Range editors should not repeat the selected range inside the expanded
  drawer when the profile row already displays that selected value. Put fixed
  slider bounds in `CatchRangeSlider.minLabel` / `maxLabel` instead.
- Profile inline multi-choice chips must keep selected check icons in both
  primitive `ChipField` usage and row-owned value-slot editors.
- Keep inline editor spacing in the shared panel: editor controls should sit
  visually close to `Cancel`/`Done`, while expanded row values need enough
  gap below the label to avoid a cramped chip stack.

### 2.3.37

- Row-owned Profile text editors should use `ProfileInlineEditableText`, not a
  boxed `CatchTextField`. The editable value must preserve the closed row's
  typography, baseline, and icon-relative position; only the cursor and a
  text-width underline should signal edit focus.
- Inline Profile editor actions now align as a trailing action group. Keep
  `Cancel`/`Done` placement in the shared inline panel so text, chip, range,
  and stepper editors do not drift.
- The Profile header should expose only the Settings button. Account-adjacent
  actions such as review history, payment history, and sign out belong in the
  Settings account section, not a second top-right overflow menu.

### 2.3.36

- Profile inline drawer animation should preserve full available width while
  animating height. Do not animate from a zero-width `SizedBox.shrink()`:
  action rows will appear to slide sideways. Use
  `ProfileInlineAnimatedBody`, which keeps the collapsed/expanded body
  full-width and fades content while `AnimatedSize` handles vertical reveal.
- Profile inline editor spacing and `Cancel`/`Done` placement belong in the
  shared inline panel, not in each field editor. Keep future text/chip/range/
  stepper edits on the shared panel path so visual tuning remains one edit.
- Bio editing now uses the same animated body contract as row-owned inline
  editors; avoid direct conditional insertion for profile edit drawers.

### 2.3.35

- Profile inline editors should open and close through
  `ProfileInlineDisclosure` / `ProfileInlineAnimatedBody`, not by conditionally
  inserting editor bodies directly into the list. This keeps drawer open/close
  transitions, row-height changes, chip option list changes, and validation
  banner changes smooth without field-local height calculations.

### 2.3.34

- `SettingsRow` should own the common settings label/value alignment. Do not
  hand-align individual two-column settings rows; pass `value` to the primitive
  and let it keep the label left and secondary value right.

### 2.3.33

- Enum-style Profile rows now mirror text-row editing: selected chip values
  render in the row value slot while expanded, and the expanded chip list shows
  only available alternatives. This removes repeated selected labels such as
  `Education` -> `High school` plus a second selected `High school` chip.
- Multi-select Profile rows use the same pattern. Selected chips stay in the
  row; tapping a selected row chip removes it from the draft when the field is
  optional and returns that value to the available chip list below.
- Added scanner coverage for old Profile chip tile editors that stack selected
  chips below the row. Keep this at zero.

### 2.3.32

- Text-style Profile rows now edit in place. `ProfileInfoTile` supports a
  `valueEditor` slot, and normal text rows use `ProfileInlineTextEntryEditor`
  so the row value becomes a compact label-less `CatchTextField` while only
  validation feedback and `Cancel`/`Done` render below the row.
- Added scanner coverage for Profile text tile editors that reintroduce the old
  stacked separate text field below a `ProfileInfoEntry`. Keep this at zero.

### 2.3.31

- `ChipField` empty-selection behavior is now tied to optionality. Optional
  single-choice fields may clear by tapping the selected chip again when
  `allowEmptySingleSelection` is enabled; required single-choice fields keep the
  selected chip selected. Required multi-choice fields also keep the final
  selected chip from being removed.
- This is another reason Profile inline chip editors should not have a separate
  `Clear` action: clearability belongs to the field contract, not a universal
  visual affordance.

### 2.3.30

- Profile inline single-choice chip editors now follow the same commit model as
  text, range, height, and multi-choice editors: tapping chips changes local
  draft state, and `Cancel`/`Done` controls commit or discard the change.
- Removed the separate `Clear` action from Profile inline chip editors. Optional
  single-choice fields clear by tapping the selected chip again, then pressing
  `Done`.
- Added scanner coverage for Profile inline chip editors that reintroduce
  separate `Clear` actions. Keep this at zero.

### 2.3.29

- Inline profile chip editors should not repeat the expanded tile label. The
  tile row already names the field, so `ChipField` now has a defaulted
  `showLabel` option and Profile inline single-/multi-choice editors set it to
  `false`.
- Added scanner coverage for Profile inline chip editors that forget
  `showLabel: false`. Keep this at zero when continuing the inline-edit
  migration.

### 2.3.28

- Migrated Create/Edit Run Club to the shared multi-step flow pattern. Future
  app forms should prefer `CatchStepFlowHeader`, step-local finite form bodies,
  and `StepperFooter` over one-off long forms when a screen has several
  distinct input groups.
- Added create-only run-club local drafts. Keep draft persistence in a
  controller/repository seam; widgets may own `TextEditingController`s and
  restoration mechanics, but repository writes and draft pruning belong outside
  presentation code.
- Added the one-hosted-club product rule. UI affordances should use
  `canCreateRunClubProvider`, while the callable remains the source of truth
  through the server-owned `runClubHostClaims/{uid}` document. Do not rely on
  hiding buttons as the only enforcement.
- Form validation lesson: do not put finite required form fields in lazily
  mounted scroll children if the form validates the whole step. Use a
  `SingleChildScrollView` with a `Column` for short step pages so validation
  covers fields that are currently offscreen.
- Scanner follow-up from this pass: draft save snackbars in Create Run and
  Create Run Club still use local `SnackBar(content: Text(...))` copy. When the
  error/snackbar queue resumes, route draft save feedback through the branded
  snackbar helper instead of one-off `Text` content.

### 2.3.27

- Started the Profile inline-edit migration. Normal Edit Profile field changes
  now expand inside the profile list instead of opening bottom sheets; the
  removed bottom-sheet surface should not be reintroduced for ordinary text,
  single-choice, multi-choice, height, or range edits.
- Added `ProfileInlineTextEditor`, `ProfileInlineSingleChoiceEditor`,
  `ProfileInlineMultiChoiceEditor`, `ProfileInlineHeightEditor`, and
  `ProfileInlineRangeEditor`. These reuse existing primitives
  (`CatchTextField`, `ChipField`, `CatchNumberStepper`, `CatchRangeSlider`,
  `CatchButton`, and `CatchTextButton`) and keep saves on
  `ProfileEditController.saveFields`.
- Expanded `tool/widget_cleanup_scan.sh` with a Profile bottom-sheet editor
  scanner. Future profile-edit work should keep this at zero and add a scanner
  for any new repeated UI failure class exposed by screenshots or tests.
- Tightened `CatchChip` so long chip labels ellipsize under narrow inline editor
  constraints instead of overflowing. This primitive-level fix should prevent
  row-specific chip patches.

### 2.3.26

- Expanded `tool/widget_cleanup_scan.sh` from screenshot-specific checks into a
  primitive-bypass scanner. It now reports raw Material/Cupertino buttons, raw
  text inputs, literal `SizedBox` spacing, feature-local decorated
  `Container`/`DecoratedBox` surface shells, and app-facing `Text` calls that
  do not have nearby `CatchTextStyles`.
- Text-only actions now route through `CatchTextButton`; pill CTAs remain on
  `CatchButton`. Do not replace inline dialog/banner/top-bar text actions with
  pill CTAs just to satisfy a scanner.
- The OTP entry field now routes through `CatchOtpCodeField`, a field-specific
  primitive that owns the hidden platform `TextField`, visible token-styled
  digit boxes, SMS autofill, digit-only input, and length limiting.
- The broad scans are triage queues, not automatic lint failures. Clear raw
  buttons and raw text inputs aggressively; migrate `SizedBox`, decorated
  surfaces, and unstyled `Text` in focused feature batches so visual intent is
  preserved.

### 2.3.24

- Added the numeric stepper cleanup loop. Feature-local paired +/- controls
  should use `CatchNumberStepper`, which owns the shared raised surface,
  compact add/remove buttons, centered mono value, optional min/max/step
  clamping, and feature-specific formatting.
- Migrated the Create Run duration control and Edit Profile height editor to the
  shared primitive. Run distance and capacity remain text fields for now by
  product decision.
- `tool/widget_cleanup_scan.sh` now flags raw paired add/remove `IconButton`
  steppers outside `CatchNumberStepper`. Future numeric-control screenshots
  should expand this scanner before adding another feature-local control.

### 2.3.23

- Added the slider primitive cleanup loop. All feature range sliders should use
  `CatchRangeSlider`, which centralizes tickless slider styling and prevents
  dashed tracks from reappearing when individual screens add `divisions`.
- `tool/widget_cleanup_scan.sh` now flags raw `RangeSlider` or `SliderTheme`
  usage outside `lib/core/widgets/catch_range_slider.dart`.
- Filters are now treated as the home for private discovery preferences. Keep
  age and interested-in filters there; do not mirror those fields in Edit
  Profile unless the public profile card starts rendering them.
- The dark primary CTA foreground is a token/default concern, not a screen
  override concern. If a future button screenshot is wrong, first verify
  whether the screen uses `CatchButton`; if yes, fix the primitive/token and add
  primitive tests rather than patching the one screen.

### 2.3.22

- Added the white-pill CTA cleanup loop. Solid white CTA fills should use
  `CatchButtonVariant.light`, which pairs a fixed white fill with
  `CatchTokens.sunsetLight.ink` instead of ambient dark-mode text tokens.
- `CatchButton` now supports non-interactive display mode for button-looking
  labels inside tappable parent cards. Do not use `onPressed: null` alone for
  decorative CTAs because disabled opacity is intentionally dimmed; do not use
  empty callbacks because that creates misleading nested tap semantics.
- `tool/widget_cleanup_scan.sh` now scans for fixed-white pill CTA candidates.
  When a future screenshot exposes a one-off primitive bypass, fix the surface
  and expand the scanner in the same pass so the bug class does not recur.

### 2.3.21

- Completed the core notification producer pass: scheduled run reminders now
  exist, Settings has granular notification categories, and run-club push
  notifications use the two-tier membership-plus-bell model. Remaining
  notification work should focus on product policy and surface-specific UI
  polish rather than missing core fan-out.
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

### 2.3.42

- Added the profile thumbnail seam: `users/{uid}` and `publicProfiles/{uid}`
  now support `photoThumbnailUrls`, Home's header avatar consumes
  `primaryPhotoThumbnailUrl` with full-photo fallback, and the avatar opens the
  Profile tab. Backend generation/backfill plus participant hype-avatar
  selection were completed in 2.3.45.

### 2.3.41

- Refactored the Dashboard next-run card flow. `DashboardFullViewModel` now
  exposes all upcoming booked runs in soonest-first order, while preserving
  `nextRun` as the first item for compatibility. `DashboardFullSliverBody`
  renders `UpcomingRunsHero`, a horizontal pager that lets users switch between
  booked upcoming runs and tap the active card into a dashboard-owned run detail
  route.
- Fixed a recurring rounded-card border issue at the shared `CatchSurface`
  primitive by moving borders into foreground decoration so clipped card/image
  children cannot paint over the outline.
- Added `DASHBOARD-RUN-HYPE-THUMBNAILS-001` to the backlog. Do not load full
  profile photos into the next-run hype avatars; add tiny backend-generated
  first-photo thumbnails and public profile projections before replacing the
  deterministic placeholder circles with blurred participant thumbnails. This
  backlog item was completed in 2.3.45.

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
status. Snapshot as of 2026-05-07:

| Debt | Status | Next action |
|---|---|---|
| `PROFILE-CARD-POLISH-001` | needs_device_confirmation | Shared Swipes/Profile Preview/Public Profile card now uses one canonical dark `RUN PROFILE` section and inset/rounded non-hero photos. Device visual review is deferred by user request. |
| `PROFILE-001` | watch | Sliver/rendering is not complete: Profile Preview still does not continuously restore the outer header from the preview-card top gesture on device. Defer implementation until after doc hygiene / stream lifecycle / error UI queue pass. |
| `CELEBRATION-SOUND-001` | identified | Haptics are live for full-screen celebration moments. Add optional sound later through `CelebrationEffectsController`, with mute/silent-mode/accessibility respect and tests using an injected fake effects controller. |
| `NOTIFICATIONS-QUEUE` | watch | Core backend fan-out is complete: match/message, club-run, signup, waitlist, reminder, schedule/location update, and cancellation producers write durable activity and preference-gated push. Remaining notification work is settings/permission UX, device QA, and run-cancellation product policy, not a missing producer queue. |
| `RUN-CANCELLATION-UI-POLICY-001` | identified | Backend cancellation notification support exists, but host cancellation UI must wait for product decisions around cancellation windows, refunds, confirmation copy, participant copy, and how cancelled runs render across detail/calendar/activity. |
| `STREAM-LIFECYCLE-QUEUE` | watch | Known Firestore listener lifecycle issues are resolved. Keep the rule active as a guardrail: new realtime streams should be auto-dispose, retained-tab gated, or explicitly documented as shell/global. |
| `ERROR-UI-QUEUE` | watch | Branded error primitives are in place, `CatchErrorText` is deleted, and the raw error-surface scanner is clean. Keep watching for regressions and add typed catalogue entries only when repeated product/domain failures need branching, analytics, retry policy, or tests. |
| `PROFILE-FIELD-PARITY-001` | watch | Shared validators and profile edit mutation UX are aligned. Nullable single-choice sheets now have root-cause coverage across all optional fields and visible immediate-save pending feedback. Keep onboarding intentionally low-friction unless product accepts the signup cost of adding more optional fields. |
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
