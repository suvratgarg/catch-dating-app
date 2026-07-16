# Host Club Edit Tab & Live Event Guide Setup Spec (for Codex)

Status: ready for implementation · 2026-07-17
Scope: `lib/hosts/`, `lib/event_success/`, `lib/clubs/domain/`, `lib/core/widgets/` (two small additions), `lib/user_profile/` (extraction only), `lib/l10n/`, `copy/structured_domain_copy_en.json`, `lib/routing/`, `design/screens/`, `widgetbook/`, `test/`
Origin: 2026-07-17 owner + Claude review of the host app organizer screen's Edit tab. All findings below were verified against the repo; evidence cited inline.

This spec restructures the host club workspace Edit tab and the "event success"
(live event guide) setup surface. Owner decisions are baked in. Items marked
`⚠ OWNER` must be escalated before implementation; everything else is
ratified by this spec and executable without further product input.

---

## 0. Background — what the surface is

The host app organizer tab routes to `HostClubsScreen` →
[`HostClubsScaffold`](../../lib/hosts/presentation/host_operations/host_clubs_scaffold.dart)
with three tabs: **Edit / Insights / Preview**. The Edit tab body is
`HostClubProfileCard` in
[`host_club_profile.dart`](../../lib/hosts/presentation/host_operations/host_club_profile.dart)
(a `part of host_operations_screen.dart`). It currently stacks, in one scroll:

1. **Media** — logo + photo strip, staged draft + Save/Cancel action bar.
2. **Identity** — name, city, area, description (inline expand → per-field save).
3. **Contact** — instagram, phone, email (same inline pattern).
4. **Event defaults** — activity, admission preset, age range, cancellation
   policy (same inline pattern).
5. **Advanced defaults** (owner only) — `ClubPolicyDefaultsCard(advancedOnly:
   true)` (cohort caps, demand pricing) + `EventSuccessDefaultsPanel` (the
   entire live event guide config), sharing ONE dirty flag and ONE action bar
   at the very bottom of the section.
6. **Payments** — `HostPaymentAccountControllerCard`.
7. **Host team** — `HostTeamManagementSection` (add via icon button in the
   section header trailing slot).

The live event guide config UI is
[`EventSuccessSetupBody`](../../lib/event_success/presentation/event_success_setup_body.dart),
shared by three `EventSuccessDefaultsPanel` call sites (club edit tab, club
create step, event create step) plus the per-event Manage → Setup tab
([`event_success_host_setup.dart`](../../lib/event_success/presentation/host_parts/event_success_host_setup.dart)).

The consumer app's profile edit tab
([`profile_tab.dart`](../../lib/user_profile/presentation/widgets/profile_tab.dart)
+ [`self_profile_edit_tab_state.dart`](../../lib/user_profile/presentation/self_profile_edit_tab_state.dart))
is the reference implementation: descriptor-driven rows, one save model
(per-field inline commit), add-affordance rows, width-constrained content.

## 1. Goals and non-goals

Goals, in priority order:

1. One save model on the whole edit surface: **every control commits its own
   change**; no section-level staged drafts, no distant action bars.
2. The Edit tab means exactly what the Preview tab previews (the public
   storefront). Everything else moves to spoke screens.
3. Live event guide setup reads in host language, grouped by the event
   timeline, with each toggle's configuration nested directly under it.
4. Kill internal vocabulary in all host-facing copy ("Default event success",
   "run-of-show defaults", "Balance across units", "host-owned count", …).
5. Reduce the live-guide decision surface from ~10 flat toggles to ~5 real
   decisions (Phase 4, gated).
6. Fix hygiene: width constraint, paired-input consistency, add-host
   affordance, stable field keys, dead plumbing.

Non-goals:

- No change to Firestore document shapes, callable payloads, or
  `contracts/` schemas in Phases 0–3. Phase 4 touches domain semantics but
  MUST NOT rewrite stored documents (see §8 back-compat rules).
- No redesign of the per-event live companion / reveal / wingman runtime
  surfaces (`event_success_companion_*`, `live_reveal_parts/`).
- No new visual identity work; everything composes existing `CatchField` /
  `CatchSection` / `CatchSurface` primitives.
- No changes to `packages/catch_ui_lints` (editing the analyzer plugin
  crashes local `dart analyze` — repo memory; do not attempt).
- The Insights and Preview tabs are untouched.
- The "plan-first / run-of-show timeline" north star (§9) is explicitly NOT
  in scope; do not partially implement it.

## 2. Findings register (verified 2026-07-17)

| # | Finding | Evidence |
|---|---------|----------|
| F1 | Three save models on one screen: per-field inline commit (identity/contact/defaults), staged media draft + action bar, and mixed advanced-defaults (toggles save immediately via an optimistic queue; everything else staged into a draft saved by an action bar below the whole section) | `host_club_profile.dart` — `_saveMedia` (~line 167), `_updateDefaultsImmediately`/`_flushImmediateDefaults` (~lines 206–264), `_saveDefaults` (~line 266), action bars at ~lines 386, 566 |
| F2 | The advanced-defaults dirty machinery needs five state fields (`_defaultsDraft`, `_defaultsConfirmed`, `_defaultsOptimistic`, `_queuedImmediateDefaults`, `_flushingImmediateDefaults`) and reconciliation in `didUpdateWidget` | `host_club_profile.dart` ~lines 33–94 |
| F3 | One action bar + one error slot serve BOTH `ClubPolicyDefaultsCard` and `EventSuccessDefaultsPanel`; errors render far from the failing field | `host_club_profile.dart` ~lines 556–572 |
| F4 | Invisible cross-section coupling: cohort caps / demand pricing toggles in "Advanced defaults" only render under admission presets edited in the "Event defaults" section above; changing preset silently disables dynamic pricing | `club_host_defaults_step.dart` ~lines 260, 302; `host_club_profile.dart` `_admissionDefaultEntry` patch (~line 707) |
| F5 | With preset = invite-only, the advanced policy card renders a section title + footer around zero rows | `club_host_defaults_step.dart` `advancedOnly` branches |
| F6 | Nested section hierarchies: `CatchSectionList` inside `CatchSection.plain("Advanced defaults")`, which itself contains the policy card's own titled section ("Default event policy" + footer) | `host_club_profile.dart` ~lines 508–575 |
| F7 | The module toggle list is titled "During the event" but contains after-event modules: contextual openers (stage `after`), decomposed feedback (`after`), host recap (`hostDebrief`) | `event_success_setup_body.dart` ~lines 168–185; stages in `modules.dart` |
| F8 | Toggle ↔ config separation: rotation cadence and reveal countdown render AFTER the whole toggle list, not nested under their toggles; the questionnaire editor is a separate sibling section from the questionnaire mode choice | `event_success_setup_body.dart` ~lines 186–275 |
| F9 | The structure editor renders unconditionally, so a host with "Small starter groups" off still sees a "Pod setup" section | `event_success_setup_body.dart` ~line 243 (no module condition) |
| F10 | Untranslated hardcoded English in presentation: panel default title/subtitle (`event_success_defaults_panel.dart` ~lines 23–24), `_questionnaireModeLabel`, `_questionnaireSubtitle`, `_structureSectionTitle`, `_revealCountdownLabel` (`event_success_setup_body.dart` ~lines 327–361). Domain enums/catalog also carry hardcoded English (`event_success_structure.dart`, generated `modules.dart`, `rules.dart`, `library.dart`) |
| F11 | Jargon copy: "Default event success", "Apply activity-aware run-of-show defaults automatically…", "Flow type", "Balance across units", "Cluster similar people", "Repeat policy", "Max meetings per pair", "Assignment goals", "Set a host-owned count…", error text literally `'Before launch'` | ARB keys listed in §5; `eventSuccessEventSuccessHostSetupTextBeforeLaunch` used as `errorText` in `event_success_setup_body.dart` ~line 132 |
| F12 | No width constraint on the host edit tab; the consumer `ProfileTab` wraps content in `ConstrainedBox(maxWidth: CatchLayout.maxContentWidth)` (600), `CatchTabbedScreenScaffold`/`CatchTabbedPageScrollView` do not | `profile_tab.dart` ~line 52; `catch_tabbed_screen.dart` (no `maxContentWidth` reference) |
| F13 | Paired numeric inputs have three treatments: age min/max side-by-side halves (`host_inline_editors.dart` `HostInlineAgeRangeEditor` ~line 533), cohort caps and pricing stacked full-width contained rows (`club_host_defaults_step.dart`) | cited files |
| F14 | Add host = tooltip-only `CatchIconButton` in the section header trailing slot; the DS already has the `CatchField.add` row constructor used by the consumer prompt editor | `host_team_management_section.dart` ~line 155; `catch_field.dart` ~line 844; `inline_editor_prompt.dart` ~line 343 |
| F15 | Field expansion keys are LOCALIZED strings (`context.l10n.…Visiblecopy…` used as `fieldName` and compared against `initialExpandedEditField`); breaks on locale change and unstable for deep links. The organizer route never passes `initialExpandedEditField` (dead plumbing) | `host_club_profile.dart` ~line 318 etc.; `go_router.dart` organizer branch (~line 872) passes only `clubId` + `tab` |
| F16 | Accordion behavior (single expanded field) duplicated verbatim in `_HostClubProfileCardState` and `_ProfileTabContentState` | both files, `_expandedField`/`_toggleField`/`_collapseField` |
| F17 | `_maxClubPhotos = 6` is a widget-local const (consumer photo cap lives in domain `profile_photo_policy.dart`); media section shows no "n of 6" count while the consumer photos section does | `host_club_profile.dart` ~line 26; `profile_tab.dart` ~line 640 |
| F18 | `_capacitySummary` renders a bare "20-80" as `valueText` with no unit | `event_success_setup_body.dart` ~line 341 |
| F19 | `HostClubProfileCard` is not a card; it is the entire tab body | naming only |
| F20 | Module inventory: 14 modules; 3 already hidden as platform (`safety_controls`, `qr_check_in`, `crowd_balance` via `_platformModuleIds`); of the visible ones, contextual openers / decomposed feedback / host recap / wingman requests are not real per-event host decisions; `micro_pods` + `guided_rotations` + the structure editor all model the same "how the room is grouped" concept (`unitKind`); `first_hello_check_in` is an arrival-mission flavor of check-in | `modules.dart`, `rules.dart` (quiz reason: "For quiz formats this is the team setup"), `event_success_structure.dart` |

## 3. Cross-cutting rules (apply to every phase)

1. **Branch discipline** (AGENTS.md): push a working branch immediately;
   `chore(wip)` snapshot before ending any dirty session. For each phase,
   generate a context pack first:
   `node tool/agent/context_pack.mjs --task host-edit-restructure-p<N> --paths lib/hosts,lib/event_success`.
2. **Copy pipeline**: `lib/event_success/domain/event_success_playbooks/modules.dart`
   is GENERATED from `copy/structured_domain_copy_en.json` +
   `tool/copy/templates/structured_domain_copy/modules.dart.template`. Never
   hand-edit it; edit the JSON and run
   `dart run tool/copy/sync_structured_domain_copy.dart`. ARB changes go in
   `lib/l10n/app_en.arb` (+ sibling locales) followed by `flutter gen-l10n`.
   When an English VALUE changes materially, rename the key to match the new
   content per the repo's content-derived key convention, update all call
   sites, and keep `node tool/run.mjs check` copy checks green
   (`tool/copy/check_l10n_key_usage.mjs`, `tool/copy/check_mobile_copy_catalog.mjs`).
3. **No new save paradigms.** The only allowed persistence patterns on these
   surfaces after Phase 3 are: (a) per-field inline commit via the existing
   inline editors, (b) the functional-update immediate queue for
   `ClubHostDefaults` (§7.3), (c) per-action media commits (§7.4). In the
   create flows the same widgets emit in-memory draft updates through the same
   callbacks — no divergence.
4. **Stable field keys.** All `fieldName` / expansion keys / deep-link keys
   become the slugs in §4.2. Never key state on `context.l10n` output.
5. **flutter tooling PATH**: `export PATH="$HOME/development/flutter/bin:$PATH"`
   before `flutter analyze` / `flutter test` / `flutter gen-l10n`.
   `flutter analyze` is authoritative over IDE state.
6. **Verification** after each phase: focused tests for touched files, then
   `flutter analyze`, then the phase's gates in §11. Stamp cleanup passes in
   `docs/audit_registry/passes.jsonl`. Record hard-won regressions in
   `docs/agent_regression_ledger.json`.
7. **Widgetbook/design registries**: screens added or restructured in Phase 3
   need `design/screens/catch.screens.json` entries and
   `docs/design_parity/state_matrix.json` states, keeping
   `node tool/run.mjs check design:screen-contracts`,
   `design:screen-coverage`, `design:widgetbook-coverage`,
   `design:section-headers` green. Widgetbook stories live under
   `widgetbook/lib/hosts/` and `widgetbook/lib/event_success/`.
8. **Do not** modify `EventSuccessPlan` runtime consumption, reveal/companion
   flows, or anything under `lib/event_success/presentation/companion_parts/`
   and `live_reveal_parts/`.

## 4. Phase 0 — Hygiene groundwork (no visual redesign)

Small, independent, land-first items. Each is one commit.

### 4.1 Width constraint on host tabbed pages

The consumer `ProfileTab` centers content in
`ConstrainedBox(maxWidth: CatchLayout.maxContentWidth)`. Host club tab pages
do not (F12).

- Add the same constraint where the Edit tab body is embedded in
  `HostClubsScaffold` (wrap the `SliverToBoxAdapter` child for the edit tab,
  and the insights pane, in a centered `ConstrainedBox(maxWidth:
  CatchLayout.maxContentWidth)`; the Preview tab already renders the consumer
  club detail sliver — leave it).
- Do NOT bake the constraint into `CatchTabbedPageScrollView` (other callers
  may be full-bleed); apply at the call sites.

Acceptance: on a wide window (e.g. `flutter run -d macos` or a widget test
with an 900 px surface), edit-tab fields cap at 600 and center.

### 4.2 Stable field keys + deep-link wiring

Replace localized `fieldName` values in
`host_club_profile.dart` with const slugs (F15):

| Field | Slug |
|---|---|
| Club name | `name` |
| City | `location` |
| Area | `area` |
| Description | `description` |
| Instagram | `instagramHandle` |
| Phone | `phoneNumber` |
| Email | `email` |
| Default activity | `primaryActivityKind` |
| Admission | `admissionPreset` |
| Age range | `ageRange` |
| Cancellation policy | `cancellationPolicyId` |

- Define them in one place (`abstract final class HostClubEditFieldKeys` next
  to the tab widget) and use for `fieldName`, `ValueKey('host-inline-…')`
  (already slug-shaped — align exactly), and `initialExpandedEditField`
  comparisons.
- Wire the dead plumbing: the organizer `GoRoute` builder
  (`go_router.dart`, organizer branch) additionally reads
  `state.uri.queryParameters['editField']` and passes it as
  `initialExpandedEditField`. Values are the slugs above; unknown values are
  ignored (current behavior already tolerates non-matches).
- Consumer app: prompt-slot `fieldName` currently uses an l10n getter
  (`self_profile_edit_tab_state.dart`, `…VisiblecopyProfilepromptIndex`).
  Replace with `'profilePrompt-$index'`. Remove the ARB key if it becomes
  unused (copy checks will flag it).

Acceptance: `flutter analyze`; existing widget tests for the edit tab pass
with keys unchanged in behavior; opening
`/host/clubs?clubId=X&editField=description` lands on the Edit tab with the
description editor expanded (add a widget test beside the existing host
operations tests in `test/hosts/`).

### 4.3 Add-host affordance

Replace the header `CatchIconButton` (F14) in
`host_team_management_section.dart` with a `CatchField.add` row appended
after the host rows, exactly like the consumer prompt add-affordance:

```dart
if (canManage)
  CatchField.add(
    title: context.l10n.hostsHostTeamManagementSectionTitleAddHost, // "Add host" — reuse existing key
    icon: CatchIcons.personAddAlt1Rounded,
    onTap: actionPending ? null : () => unawaited(showAddHostSheet()),
  ),
```

- Remove the `trailing:` icon button entirely (the section header keeps only
  the title).
- Keep the existing bottom sheet, mutation wiring, dialogs, and snackbars.
- Keep the empty state (`CatchField.read` "No host team members…") ABOVE the
  add row.

Acceptance: widget test asserting the add row exists for `canManage: true`,
absent otherwise, and opens the sheet.

### 4.4 Shared accordion scope (extraction, F16)

Extract the duplicated single-expanded-field logic into
`lib/core/widgets/catch_field_accordion.dart`:

```dart
/// Owns "at most one expanded inline editor" state for a field list.
class CatchFieldAccordion extends ChangeNotifier {
  String? _expanded;
  String? get expanded => _expanded;
  bool isExpanded(String key) => _expanded == key;
  void toggle(String key) { _expanded = _expanded == key ? null : key; notifyListeners(); }
  void collapse() { if (_expanded == null) return; _expanded = null; notifyListeners(); }
}
```

- Name ratified by owner via this spec.
- Adopt in `_HostClubProfileCardState` and `_ProfileTabContentState`
  (replace `_expandedField`/`_isExpanded`/`_toggleField`/`_collapseField`).
  Mechanical; zero behavior change. Add a unit test in `test/core/`.
- Do not migrate other accordion-ish call sites in this pass.

### 4.5 Club media policy + count

- Move `_maxClubPhotos` to domain: add `maxClubPhotos = 6` to the club domain
  (new `lib/clubs/domain/club_media_policy.dart`, mirroring
  `user_profile/domain/profile_photo_policy.dart`).
- Media section header gains `count:` "n of 6 added" using the existing
  consumer pattern (`CatchSection.fieldRows(count: …)` — see
  `profile_tab.dart` `ProfilePhotosSection`). New ARB key mirroring
  `userProfileProfileTabVisiblecopyCompletedcountOf…` for the club wording.

### 4.6 Paired numeric input convention

Canonical treatment for min/max-style pairs = **two half-width inputs
side-by-side in one row** (the `HostInlineAgeRangeEditor` treatment,
`host_inline_editors.dart` ~line 533). Migrate in
`club_host_defaults_step.dart` (F13):

- Cohort caps: "Max straight men" / "Max straight women" → one
  `Row(children: [Expanded(input), gapW12, Expanded(input)])` inside the
  existing `CatchSection.containedFieldRows`.
- Demand pricing: "Step" / "Max" → same row treatment.
- Keep icons, validators, formatters, controllers as-is.

Acceptance: `flutter analyze`; existing `test/hosts/` create-club step tests
updated for structure; visual check in Widgetbook story for the defaults step
(add story if missing).

## 5. Phase 1 — Copy pass (host language, l10n completeness)

No structural changes. Two workstreams.

### 5.1 l10n the stragglers (F10)

Move to ARB + `context.l10n` (or, for the two widget-default cases, require
the caller to pass copy):

| Location | Strings |
|---|---|
| `event_success_defaults_panel.dart` ~23–24 | default `title`/`subtitle` parameter values — make both REQUIRED parameters; all three call sites already pass or will pass explicit l10n values (see §5.2 table) |
| `event_success_setup_body.dart` `_questionnaireModeLabel` | 'Off', 'Clues only', 'Clues + soft pairing' |
| `event_success_setup_body.dart` `_questionnaireSubtitle` | all three sentences |
| `event_success_setup_body.dart` `_structureSectionTitle` | replaced entirely in §5.2 |
| `event_success_setup_body.dart` `_revealCountdownLabel` | replaced entirely in §5.2 |

Domain-layer English (module catalog, playbooks, `rules.dart` reasons,
`event_success_structure.dart` enum labels) is **declared English-only domain
copy for now** — owner decision; do NOT attempt to route the generated
catalog through l10n in this spec. Copy VALUE changes to those files follow
§3.2 (JSON + sync for `modules.dart`; direct edits for `rules.dart` /
`event_success_structure.dart` / `library.dart`).

### 5.2 Replacement copy (owner-ratified)

Apply exactly; keys renamed to match new content per §3.2. "Section/title"
column says where it appears.

Chrome and sections:

| Where | Current | New |
|---|---|---|
| Panel title at club-create step + club edit tab (`hostsClubEventSuccessDefaultsStepTitleDefaultEventSuccess`) | "Default event success" | "Live event guide" |
| Panel subtitle same sites (`…SubtitleApplyActivityAwareRun`) | "Apply activity-aware run-of-show defaults automatically when creating new events." | "New events start with a ready-to-run plan for this activity. You can adjust any event's plan later." |
| Panel subtitle at event-create step (`hostsEventSuccessStepSubtitleSaveASimplePlan`) | "Save a simple plan with this event so Live mode is ready when it starts." | keep as-is (already host language) |
| Master toggle body default (currently hardcoded) | "Choose whether new events should get a saved live plan." | "Give the event a run-of-show — check-in, icebreakers, timed rounds and reveal moments — run from your phone." |
| Setup section title (`eventSuccessEventSuccessHostSetupTitleRecommendedSetup`) | "Recommended setup" | "Your plan" |
| Edit-tab section title (`hostsHostClubProfileTitleAdvancedDefaults`) | "Advanced defaults" | "Advanced event defaults" (interim; section dissolves in Phase 3) |
| Format read row valueText (`_capacitySummary`, F18) | "20-80" | "20–80 guests" (l10n key with placeholder) |
| Host goal field title (`…SetupBodyTitleHostGoal`) | "Host goal" | "Your goal for the event" |
| Host goal empty error (`eventSuccessEventSuccessHostSetupTextBeforeLaunch`) | "Before launch" | "Add a goal so the live guide knows what to aim for." |
| Attendee prompt title (`…SetupBodyTitleAttendeePrompt`) | "Attendee prompt" | "Message to attendees" |
| Attendee prompt placeholder (`…PlaceholderPromptAttendeesBeforeOr`) | "Prompt attendees before or after the event." | "Something attendees see before the event kicks off." |
| Toggle list section (`…SetupBodyTitleDuringTheEvent`) | "During the event" | superseded by Phase 2 stage buckets (§6.2); if Phase 1 lands alone first, interim rename to "Live tools" |
| Rotation cadence (`…SetupBodyLabelRotationCadence`) | "Rotation cadence" | "Switch partners every" |
| "No timed rotation" option | "No timed rotation" | "No timer" |
| Reveal countdown label (unit-specific builder) | "Team/Table/Pair/Pod reveal countdown" | single label "Reveal countdown" (delete `_revealCountdownLabel`) |
| Structure section title map (`_structureSectionTitle`) | "Group flow"/"Pod setup"/"Pair setup"/"Team setup"/"Table setup" | single title "How the room is grouped" |
| Flow type (`…StructureConfigEditorTextFlowType`) | "Flow type" | "Group people into" |
| Auto-count helper (`…DetailSetAHostOwned`) | "Set a host-owned count or let Catch estimate it from attendance." | "Set the number yourself, or let Catch work it out from attendance." |
| Balance choices (`…TitleBalanceAcrossUnits`) | "Balance across units" | "Spread people out by" |
| Cluster choices (`…TitleClusterSimilarPeople`) | "Cluster similar people" | "Keep similar people together by" |
| Both bodies (`…TextAssignmentGoals`) | "Assignment goals" | "Catch uses this when it builds the groups." |
| Repeat policy (`…TextRepeatPolicy`) | "Repeat policy" | "Meeting the same person again" |
| `EventSuccessRotationRepeatStrategy.allowWhenExhausted` label (`event_success_structure.dart`) | "Fill extra rounds" | "Allow when rounds run long" |
| Max meetings (`…LabelMaxMeetingsPerPair`) | "Max meetings per pair" | "Max times the same pair meets" |
| Max meetings body (`…DetailCapsRepeatPairingsWhen`) | "Caps repeat pairings when rounds outnumber attendees." | "Only used when there are more rounds than people to meet." |
| Questionnaire mode labels (new ARB keys) | 'Off' / 'Clues only' / 'Clues + soft pairing' | keep wording, l10n'd |
| Questionnaire subtitles (new ARB keys) | as in `_questionnaireSubtitle` | keep wording, l10n'd |

Module catalog (`copy/structured_domain_copy_en.json` → regenerate
`modules.dart`): titles are already good host language — change ONLY:

| Module | Field | Current | New |
|---|---|---|---|
| `first_hello_check_in` | title | "First Hello check-in" | "Arrival icebreaker" |
| `qr_check_in` | title | "Attendance and live roster" | keep (hidden from hosts anyway) |
| `decomposed_feedback` | title | "After-event attendee feedback" | "Attendee feedback" |

Everything else in the catalog (attendee/host promises, reasons in
`rules.dart`, playbook copy) stays as-is in this phase.

### 5.3 Acceptance

- `rg -n "…" lib/event_success/presentation` shows no hardcoded UI strings in
  the touched presentation files (the repo copy checks are authoritative:
  run `node tool/copy/check_mobile_copy_catalog.mjs` per manifest wiring and
  `tool/copy/check_l10n_key_usage.mjs`).
- `dart run tool/copy/sync_structured_domain_copy.dart` produces a clean
  regenerated `modules.dart`; `flutter gen-l10n`; `flutter analyze`.
- Update `test/event_success/event_success_setup_body_test.dart`,
  `…_structure_config_editor_test.dart`, `…_playbooks_test.dart` string
  expectations.

## 6. Phase 2 — Live event guide panel regroup (presentation only)

All changes inside `event_success_setup_body.dart` (+ the two config editors
it embeds). Zero domain changes; `EventSuccessHostDraft` and
`EventSuccessDefaults` untouched. The same body renders at all four surfaces
(three panel call sites + per-event Setup tab), so this lands everywhere at
once — verify each surface after.

### 6.1 Target layout (top to bottom, when master toggle is on)

1. **"Your plan"** (`CatchSection.fieldRows`): format read row (title =
   `profile.formatLabel`, body = `profile.summary`, valueText = "20–80
   guests", Reset action unchanged) → "Your goal for the event" input →
   "Message to attendees" input. Unchanged apart from copy.
2. **Stage buckets** replace the flat "During the event" list (F7). Bucket a
   module by `module.stage`:

   | Stage(s) | Section title (new ARB keys) |
   |---|---|
   | `before` | "Before the event" |
   | `arrival` | "When people arrive" |
   | `opening`, `activity`, `mixing`, `closing` | "During the event" |
   | `after`, `hostDebrief` | "After the event" |

   Render buckets in that order; omit empty buckets. Within a bucket, keep
   catalog order. Each module renders as today
   (`CatchField.toggle(title: module.title, body: recommendation.reason)`).
   The existing filters stay: `recommendation.selectable`, not in
   `_platformModuleIds`. The compatibility questionnaire is no longer
   excluded from the list — it moves INTO the "Before the event" bucket as
   the mode choice row (see 6.3).
3. **Nested config** (F8): when a toggle is on, its config renders directly
   beneath it inside `CatchSection.containedFieldRows` (the cohort-caps
   pattern from `club_host_defaults_step.dart` ~line 276):
   - `guided_rotations` → "Switch partners every" choices (null/10/15/20/30).
   - `live_reveal` → "Reveal countdown" choices (0/5/10/15).
4. **"How the room is grouped"** (F9): the structure editor
   (`EventSuccessStructureConfigEditor`) renders as one section at the END of
   the "During the event" bucket, and ONLY when
   `draft.isModuleSelected(microPods) || draft.isModuleSelected(guidedRotations) || draft.isModuleSelected(liveReveal) || draft.structureConfig.unitKind != EventSuccessUnitKind.wholeGroup`.
   Pass `sectionTitle:` = the new single title. The editor's internals keep
   their Phase 1 copy; no field logic changes.
5. **Match clue questions** (see 6.3) in the "Before the event" bucket, with
   the questionnaire editor nested contained beneath when mode ≠ off.

### 6.2 Recommendation-level badges (small, do it)

On each module toggle row, surface `recommendation.level` for
`recommended` and `discouraged` only (reuse the enum's `label`:
"Recommended" / "Advanced"). Render the level through
`CatchField.toggle(badgeLabel:)` and keep `recommendation.reason` as the
body with `bodyMaxLines: 3`. Keep `defaultOn`/`optional` unlabelled (silence
is the default state).

### 6.3 Questionnaire row

Keep the existing 3-mode radio (`_QuestionnaireMode`) — it is well designed —
but move it into the "Before the event" bucket, and nest
`EventSuccessQuestionnaireConfigEditor` inside `containedFieldRows` under it
(mode ≠ off) instead of rendering as a sibling section.

### 6.4 Acceptance

- Update `test/event_success/event_success_setup_body_test.dart`: assert
  bucket titles, assert cadence choices only render (and render adjacent /
  contained) when rotations toggled on, assert structure section absent when
  no grouping module is on and `unitKind == wholeGroup`, assert openers /
  feedback / recap toggles appear under "After the event".
- Manually verify all four surfaces (club edit tab, club create step, event
  create step, per-event Manage → Setup) render without overflow at 360 px
  width. Add/refresh the Widgetbook story for `EventSuccessSetupBody` under
  `widgetbook/lib/event_success/` with knobs for unit kind + module toggles.
- `flutter analyze`; design checks per §3.7 stay green.

## 7. Phase 3 — Edit tab IA split + save-model unification

The big one. Land as a stack of small PRs in the order below.

### 7.1 New spoke screens and routes

Add four host-audience routes (mirror the existing
`Routes.hostSettingsScreen` registration pattern in `go_router.dart`; all
take `clubId` as a query parameter and resolve the club the same way
`HostClubsScreen` does):

| Route enum | Path | Screen | Content (moved, not rewritten) |
|---|---|---|---|
| `hostClubEventDefaultsScreen` | `/host/clubs/event-defaults` | `HostClubEventDefaultsScreen` | The "Event defaults" inline rows (activity, admission, age range, cancellation) + `ClubPolicyDefaultsCard(advancedOnly: true)` merged into ONE section flow — the admission row and its dependent cohort-caps/demand-pricing disclosures finally live together (fixes F4/F5/F6: render caps/pricing as contained rows nested under the admission row, same pattern as §6.1.3) |
| `hostClubLiveGuideScreen` | `/host/clubs/live-guide` | `HostClubLiveGuideScreen` | `EventSuccessDefaultsPanel` (title "Live event guide", subtitle per §5.2) |
| `hostClubTeamScreen` | `/host/clubs/team` | `HostClubTeamScreen` | `HostTeamManagementSection` |
| `hostClubPaymentsScreen` | `/host/clubs/payments` | `HostClubPaymentsScreen` | `HostPaymentAccountControllerCard` |

- Screens are thin scaffolds: `CatchScreenTopBar` (eyebrow = club name, title
  = section name), `ListView` with `CatchInsets` page padding, the moved
  widget, `CatchScrollTerminalPadding`, and the §4.1 width constraint.
- Non-owner hosts: event-defaults and live-guide screens render the read-only
  `CatchField.read` variants (logic already exists in the moved code);
  payments route is owner-only (guard like the current `if (isOwner)`);
  team screen visible to all hosts with `canManage` gating actions
  (current behavior).
- Register each screen in `design/screens/catch.screens.json` +
  `docs/design_parity/state_matrix.json` with loading/error/read-only/loaded
  states, and add a Widgetbook story per screen under
  `widgetbook/lib/hosts/`.

### 7.2 Edit tab becomes the storefront

`HostClubProfileCard` (rename → `HostClubEditTab`, file
`host_club_edit_tab.dart`, still `part of host_operations_screen.dart`; F19)
keeps ONLY:

1. Media (per 7.4)
2. Identity
3. Contact
4. New final section `CatchSection.fieldRows(title: <"Club settings"> )` with
   `CatchField.nav` rows → the four spokes:
   - "Event defaults" (valueText: current activity label)
   - "Live event guide" (valueText: "On"/"Off" from
     `hostDefaults.eventSuccessForActivity(primaryActivityKind).enabled`)
   - "Payments" (owner only)
   - "Host team" (valueText: host count)

New ARB keys for the section title and the four row labels + the On/Off
values. The Edit ↔ Preview pairing is now exact: everything editable on the
Edit tab is visible on Preview.

### 7.3 Defaults save model — kill the staged draft

Replace the F1/F2/F3 machinery. Extract the existing immediate-queue into a
reusable state object so spokes share it:

- New file `lib/hosts/presentation/club_management/host_club_defaults_saver.dart`:

  ```dart
  typedef ClubHostDefaultsUpdate = ClubHostDefaults Function(ClubHostDefaults current);

  /// Serialized optimistic writer for ClubHostDefaults patches.
  /// Apply-function queue: coalesces rapid updates, one in-flight
  /// updateClub mutation at a time, reverts optimistic state to the last
  /// confirmed value on failure. Lifted verbatim from the former
  /// _HostClubProfileCardState immediate-defaults path.
  class HostClubDefaultsSaver { … }
  ```

  Port `_updateDefaultsImmediately` + `_flushImmediateDefaults` +
  `didUpdateWidget` reconciliation into it, exposing
  `apply(ClubHostDefaultsUpdate update)`, `optimistic`,
  `errorMessage`, and a `Listenable`. Delete `_defaultsDraft`,
  `_defaultsConfirmed` duplication from the widget layer.
- **Every control commits through `apply`.** Toggles already do. Choice
  chips, steppers, and the questionnaire editor switch from the staged
  `onChanged` path to the immediate path. Concretely:
  `EventSuccessDefaultsPanel` and `EventSuccessSetupBody` drop the dual
  `onChanged` + `onImmediateChanged` API in favor of ONE functional-update
  callback `ValueChanged<EventSuccessDefaultsUpdate>` /
  `ValueChanged<EventSuccessHostDraftUpdate>`. In create flows the callback
  just applies the update to the in-memory draft — identical widget code,
  no persistence.
- **Text fields** (host goal, attendee prompt, and the numeric inputs in the
  policy card) commit on explicit save / field blur using the
  `CatchField.inputActions` pattern already used by
  `HostInlineTextEntryEditor` — NOT keystroke-by-keystroke through the queue.
- Delete the section-level `CatchFieldActionBar` for defaults and the shared
  dirty flag. Error display moves adjacent to the failing control (the
  saver's `errorMessage` renders as a `CatchFieldSupportRow` directly under
  the control group that owns the failed patch).
- The per-event Setup tab (`event_success_host_setup.dart`) KEEPS its
  explicit save flow (plans have a persistence boundary + frozen states);
  adapt it to the new single-callback body API with a local functional-update
  applier. Do not change its save semantics.

### 7.4 Media save model — per-action commit

Match the consumer photos behavior (immediate per action) without changing
the repository API: after each pick / remove / reorder / logo pick, run the
existing `updateClubMedia` mutation with the full current draft list.

- Pick photos → commit immediately after selection.
- Remove → commit immediately.
- Reorder → debounce 400 ms after the last drop, then commit.
- Logo pick → commit immediately.
- While pending, interactions stay disabled (guards already exist).
  On failure, revert `_mediaDrafts` to the last committed list and show the
  existing error row.
- Delete `_clubPhotosTouched`, `_mediaDirty`, `_cancelMedia`, the media
  action bar, and `_saveMedia`'s staged semantics.

⚠ OWNER checkpoint before building 7.4: if `updateClubMedia` uploads all new
photos on every call (re-upload cost per action), fall back to keeping the
staged model for the photo strip ONLY (logo still immediate) and note the
decision in the PR. Inspect
`HostClubEditController.updateClubMedia` first; if it skips already-uploaded
inputs (`HostExistingClubPhotoInput`), per-action commits are safe.

### 7.5 Cross-field side effect surfaced (F4)

Changing admission preset away from `balancedSingles` still auto-disables
dynamic pricing (domain rule, keep it) — but now the pricing toggle lives on
the same screen, nested under the admission row, so the state change is
visible. Additionally set the admission row's `helperText` to the selected
preset's description (already available via
`selectedAdmissionPreset.description(l10n)`).

### 7.6 Cleanup

- Delete now-unused pieces of `host_club_profile.dart` (media/defaults
  state machine, advanced section) and `host_club_edit_helpers.dart` entries
  that only served them. `dart tool/audit_registry.dart refresh` if the
  registry tracks the removed widgets; ledger any removed `Catch*` usages per
  the consolidation worklog rules only if a consolidation decision is
  touched (none expected).
- Keep `HostClubTab` enum as edit/insights/preview (unchanged tab rail).

### 7.7 Acceptance

- Widget tests: edit tab renders exactly 4 sections; nav rows push the
  correct routes with `clubId`; spoke screens render owner and non-owner
  variants; defaults saver unit tests (coalescing, failure revert — port the
  scenarios the old `_flushImmediateDefaults` handled); media per-action
  commit test with a mocked controller.
- All four `EventSuccessSetupBody` surfaces compile against the single
  callback API; `test/event_success/` suite green.
- `flutter analyze`; `flutter test test/hosts test/event_success`;
  design gates (§3.7) green including new screen contracts;
  `node tool/agent/check_agent_readiness.mjs` before handoff.

## 8. Phase 4 — Module consolidation (domain; GATED)

⚠ OWNER: do not start this phase without an explicit go-ahead on this spec
section; it changes what hosts can configure. Everything below is the agreed
direction and back-compat contract.

### 8.1 Always-on modules (remove four toggles)

`contextual_openers`, `decomposed_feedback`, `host_analytics`,
`wingman_requests` stop being host decisions (F20):

- Add `hostConfigurable: false` for these four in
  `copy/structured_domain_copy_en.json` + the module template (new field on
  `EventSuccessModule`, default `true`); regenerate.
- UI: extend the existing hidden-module filter to
  `!module.hostConfigurable` (replaces the hand-kept `_platformModuleIds`
  set with catalog truth; fold the three current platform ids into
  `hostConfigurable: false` too and delete the set).
- Write path: whenever `selectedModuleIds` is produced from a draft
  (`EventSuccessDefaults.fromDraft`, plan creation), union in every
  non-configurable module id the active playbook contains.
- Read path (back-compat): stored docs whose `selectedModuleIds` lack these
  ids are treated as having them — implement in
  `EventSuccessDefaults.toDraft`/`normalizedForFormat` and
  `EventSuccessPlan` draft hydration. NEVER rewrite stored documents to add
  them.
- `EventSuccessDefaults.wingmanRequestsEnabled` /
  `contextualOpenersEnabled` fields: keep serialized (schema untouched),
  hardcode to `true` at write time, mark `@Deprecated` in the domain class
  comment for a later contract change. Run
  `./tool/check_data_contract.sh` — expected NO contract diff.

### 8.2 First Hello merge (relabel only)

Already relabelled "Arrival icebreaker" in Phase 1. No id change. Nothing
else to do — listed here so nobody invents a schema migration for it.

### 8.3 Grouping unification ⚠ OWNER (design sign-off required)

Collapse `micro_pods` + `guided_rotations` toggles + the structure section
into ONE composite decision "How people mix": a unit-kind choice row (Whole
group / Pods / Pairs / Teams / Tables) whose selection derives module state:

| unitKind | modules on |
|---|---|
| wholeGroup | neither |
| pods | `micro_pods` |
| pairs / teams / tables with a rotation cadence set | `guided_rotations` (+ `micro_pods` stays off) |

with size/count/cadence/repeat fields nested beneath, and the reveal toggle
remaining separate. Module ids and stored shapes unchanged; the mapping is a
pure presentation-layer projection with the derivation implemented next to
the draft (`EventSuccessHostDraft` extension). Escalate the interaction
design (exact row order, what happens to recommendation reasons) to the
owner with a Widgetbook prototype BEFORE wiring into production surfaces.

### 8.4 Acceptance

- Round-trip tests in `test/event_success/`: legacy defaults docs (no
  always-on ids) hydrate as on; drafts serialize with the union; playbook
  tests updated.
- `./tool/check_data_contract.sh` clean; no Firestore rules or callable
  changes.
- Toggle count visible to a host for the singles-mixer playbook drops from
  ~10 to ≤5 (test asserts the rendered toggle list).

## 9. Out of scope / north star (do NOT build now)

Recorded so future work has an anchor; no code in this spec's scope:

1. **Plan-first setup**: render the recommended plan as a summary
   ("Teams of 5 · reveal at kickoff · prompts between rounds") with a
   Customize disclosure, reusing `PlanSummary` / `HostActivitySummary` from
   the per-event Setup tab; toggles become edits to a visible run-of-show
   timeline (the playbooks already author `runOfShow` steps with durations).
2. **Attendee preview everywhere**: "See what attendees see" entry points
   from defaults surfaces. A per-event preview screen already exists
   (`Routes.eventSuccessPreviewScreen`); defaults-level preview needs a
   synthetic event and is a product feature, not a refactor.
3. Routing the generated domain copy catalog through l10n.

## 10. Sequencing

```
Phase 0 (any order, parallel-safe)  →  Phase 1  →  Phase 2  →  Phase 3
                                                        Phase 4 ⚠ gated, after 3
```

- Phases 0–2 are independent of the IA split and deliver most of the
  host-comprehension win; ship them even if Phase 3 slips.
- Phase 1 before Phase 2 (Phase 2 asserts on new copy).
- Within Phase 3: 7.1 spokes (behind nothing — routes are additive) → 7.3
  saver extraction → 7.2 tab slim-down (the move) → 7.4 media → 7.6 cleanup.
- Do not interleave Phase 4 with anything.

## 11. Verification gates (run per phase; all must pass before handoff)

```sh
export PATH="$HOME/development/flutter/bin:$PATH"
flutter analyze
flutter test test/hosts test/event_success test/user_profile test/core
flutter gen-l10n                                   # after ARB edits
dart run tool/copy/sync_structured_domain_copy.dart # after copy JSON edits
node tool/run.mjs check design:screen-contracts
node tool/run.mjs check design:screen-coverage
node tool/run.mjs check design:widgetbook-coverage
node tool/run.mjs check design:section-headers
node tool/run.mjs check --manifest-only            # if any tool entries changed
./tool/check_data_contract.sh                      # Phase 4 only
node tool/agent/check_agent_readiness.mjs
```

Plus: copy checks wired in the manifest (`tool/copy/check_l10n_key_usage.mjs`,
`tool/copy/check_mobile_copy_catalog.mjs`), `node tool/test_inventory.mjs`
regeneration if test files were added, `docs/audit_registry/passes.jsonl`
stamp per phase, and a `docs/agent_regression_ledger.json` entry for any
hard-won regression.

## 12. Confirmed healthy — do NOT "fix"

- The inline expand → per-field-save editors (`HostInlineTextEntryEditor`,
  `HostInlineOptionEditor`, `HostInlineAgeRangeEditor`) and their consumer
  counterparts — this is the target pattern, not a problem.
- The consumer profile edit tab's descriptor architecture
  (`SelfProfileEditTabState` → `ProfileFieldRow`) — reference
  implementation; Phase 0 extracts its accordion, nothing else changes.
- The module catalog's attendee/host promise copy and the per-format
  recommendation reasons (`rules.dart`) — good host language; keep.
- The 3-mode questionnaire radio (Off / Clues only / Clues + soft pairing).
- The recommendation-level gating of modules per interaction model
  (`_levelsForFormat`) and the platform-module concept.
- The per-event Setup tab's explicit save + frozen-state model
  (`event_success_host_setup.dart`) — different persistence boundary,
  intentionally different save UX.
- `EventSuccessDefaults.normalizedForFormat` reconciliation logic — subtle
  but correct; Phase 4 extends it, do not rewrite it.
- The Edit / Insights / Preview tab rail and club switcher in
  `HostClubsScaffold`.
