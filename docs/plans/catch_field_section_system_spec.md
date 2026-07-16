# CatchField / CatchSection System Review & Hardening Spec (for Codex)

Status: assessment ratified · hardening phases ready for implementation · 2026-07-17
Scope: `lib/core/widgets/catch_field.dart`, `lib/core/widgets/catch_section_layout.dart`, `lib/core/forms/` (new, Phase D), `test/core/`, `widgetbook/`, `docs/design_language.md`, `docs/widget_catalog.md`
Companions: [`host_club_edit_and_live_guide_spec.md`](host_club_edit_and_live_guide_spec.md) ("edit spec"), [`host_club_insights_spec.md`](host_club_insights_spec.md) ("insights spec") — coordination points in §11, including ONE superseded line in the edit spec (§8.2 here).
Origin: 2026-07-17 owner + Claude system review. Every number below was
measured against the working tree on that date; §1 includes the census
commands so the numbers can be re-run.

Items marked `⚠ OWNER` need explicit go-ahead; everything else is ratified
by this doc.

---

## 0. What the system is

`CatchField` is the canonical row primitive: one widget, five internal modes
(`edit, read, nav, toggle, select`), exposed through 14 named
constructors/factories (`read, content, nav, action, toggle, input, control,
expanding, actions, inputActions, add, select, choices, stepper`), with
row/underline/bare variants, three sizes, three tones, and an explicit-save
status lane (`idle/saving/saved`). Supporting public classes live in the
same file: `CatchFieldRow`, `CatchFieldContentRow`, `CatchFieldTrailing`,
`CatchFieldSupportRow`, `CatchFieldActionBar`, `CatchFieldExplicitSaveControl`,
`CatchFieldDisclosureDrawer`, `CatchFieldToggle`, `CatchFieldChoiceControl`,
`CatchFieldVisibilityScope`, `CatchFieldInsetScope`, plus
`CatchFieldAccordion` (separate file, added 2026-07-17 per edit spec §4.4).

`CatchSection` is the canonical grouping primitive: `divided`, `fieldRows`,
`containedFieldRows`, `plain` variants with `title/count/trailing/footer/
first/lead` slots and divider-role control, plus `CatchSectionList` /
`CatchSectionStack` rhythm wrappers.

Sizes (2026-07-17): `catch_field.dart` = **4,799 lines**, private constructor
= **84 parameters**, `_CatchFieldState` ≈ **2,270 lines** serving all modes.
`catch_section_layout.dart` = 1,074 lines.

## 1. Usage census (2026-07-17)

Constructor call sites in `lib/` (excluding the defining files):

| CatchField | count | | CatchSection | count |
|---|---|---|---|---|
| `.input` | 81 | | `.fieldRows` | 58 |
| `.read` | 39 | | `.divided` | 44 |
| `.choices` | 31 | | `.plain` | 14 |
| `.nav` | 23 | | `.containedFieldRows` | 10 |
| `.toggle` | 19 | | | |
| `.content` | 7 | | | |
| `.stepper` | 6 | | | |
| `.select` | 5 | | | |
| `.control` | 4 | | | |
| `.action` | 3 | | | |
| `.add` | 2 | | | |
| `.inputActions` | 1 | | | |
| `.expanding` | **0** | | | |
| `.actions` | **0** | | | |

`expanding` and `actions` also have **zero** widgetbook usages — they are
dead API.

Per-feature file distribution (files containing `CatchField`): hosts 21,
user_profile 8, event_success 8, onboarding 5, reviews/chats/core 2 each,
then a 1-file tail. Browse/emotional surfaces are Field-free or nearly so
(explore 0 field files, dashboard 1, clubs 1) while using `CatchSection` as
editorial scaffolding (dashboard 5, clubs 5, events 5, explore 1).

Census commands (re-run to refresh):

```sh
for c in read content nav action toggle input control expanding actions \
  inputActions add select choices stepper; do
  printf 'CatchField.%s: ' "$c"
  rg "CatchField\.$c" lib --type dart -g '!lib/core/widgets/catch_field.dart' | wc -l
done
rg -l 'CatchField' lib --type dart -g '!lib/core/widgets/*' \
  | awk -F/ '{print $2}' | sort | uniq -c | sort -rn
```

## 2. Assessment

### 2.1 What is genuinely well designed

1. **Right concept, right altitude.** One canonical row primitive with mode
   facades + one canonical grouping primitive. Call sites read declaratively
   (`CatchField.toggle(title:, body:, value:, onChanged:)`), which is why
   adoption is broad AND uniform: ~300 call sites across ~60 files with
   dividers, insets, focus, and save affordances consistent **by
   construction**. The 2026-06 debt inventory found the real UI debt was
   structural (ad-hoc `BoxDecoration` surfaces, 489 private widgets); this
   system is the consolidation answer, and the census shows it worked.
2. **It encodes behavior, not just looks**: explicit-save lanes and commit
   bars, disclosure drawers, add-affordances with l10n-aware canonical empty
   copy (`CatchField.defaultEmptyValueText`), inset/visibility scopes, a
   shared accordion. It carries the app's save-model philosophy, not a
   visual skin.
3. **The joints are right.** The two 2026-07-17 companion redesign specs
   (edit tab, insights tab) compose ENTIRELY from existing slots — stage
   buckets, nested `containedFieldRows`, add rows, nav spokes, section
   `count`/`trailing`/`footer`. Redesigns that need no new primitives are
   the strongest evidence a system has the right decomposition.
4. **Governance is real.** `docs/widget_catalog.md` reads as a contract
   journal ("fieldRows owns every separator", "rows are the only interactive
   layer"), and Widgetbook + contract stories exist
   (`widgetbook/lib/primitives/primitive_contract_use_cases.dart`).

### 2.2 What is not

1. **God-widget internals.** 4,799 lines, an 84-parameter private
   constructor, one ~2,270-line State class serving five modes. The facades
   hide it, but invalid parameter combinations are representable (guarded
   only by scattered asserts), and any mode change risks every mode. This is
   the same "primitive monolith" pattern the 2026-07-12 web audit flagged in
   `primitives.tsx` (4,977 lines) — the Flutter twin, better disguised
   because the public API is good. The web side was split; same medicine
   here (§7), with zero public-API change.
2. **Facade sprawl with dead limbs**: `expanding`/`actions` have zero
   usages anywhere; `inputActions` 1, `control` 4, `action` 3, `add` 2.
   Fourteen entry points, roughly nine earning their keep.
3. **Slot gaps push callers around the system**: `toggle` has no
   supporting/badge slot (both companion specs hit this — the edit spec
   resorted to a body-prefix hack, §8.2), and `choices` lacks helper text +
   per-item accent, which is why `HostInlineOptionEditor` hand-rolls a chip
   `Wrap` inside a `control:` escape hatch.
4. **The system stops one layer too low.** The consumer profile tab built a
   descriptor layer (`SelfProfileEditTabState` → `ProfileFieldRow`); the
   host edit tab hand-rolled `_textEntry(...)` builders; onboarding rolls
   its own again. The real tax of heavy usage is duplicated form
   orchestration ABOVE the widget, not the widget itself.
5. **Tests mirror the monolith.** Coverage is real — a 580-line focus
   semantics suite, `CatchFieldAccordion` tests, and substantial CatchField
   behavior tests (control expansion/release, focus retention, saving
   chrome, choices selection, drawer press states) — but the bulk lives
   inside the 7,176-line `test/core/catch_primitives_test.dart` catch-all.
   There is no per-mode contract matrix you can point a refactor at.

### 2.3 Is it over-used? (owner question, answered)

**No.** The census says Field lives where it belongs: edit / config /
settings / onboarding surfaces. Browse and emotional surfaces (explore,
dashboard, event/club detail) use Section as editorial scaffolding and
almost no Field — they run on the polaroid/ticket/hero idioms per
`docs/design_language.md`. Building a second row system would violate the
repo's own rule ("same concepts converge on one canonical contract") and is
explicitly rejected.

The real risk is drift, not overuse: Field is the path of least resistance,
so it will creep into surfaces that deserve expressive UI (the Insights tab
was the live example — a scorecard is not field rows, and the insights spec
deliberately composes stat strips + chart + tiles instead). Doctrine, not
rationing: **Field is for entering and managing data; it is forbidden as a
storytelling surface.** Codified in Phase E.

### 2.4 Rating (owner asked)

- API design & concept: **8.5/10** (facade ergonomics, behavioral encoding,
  right joints; docked for dead limbs + missing slots)
- Implementation: **6/10** (monolith internals, 84-param ctor, test
  organization; better than it looks from the outside, worse than the API
  deserves)
- Adoption & governance: **8.5/10** (census discipline, catalog journal,
  correct browse/edit division)
- **Overall: 7/10.** Phases A–D below are the path to ~8.5; none of them is
  a redesign — the scarce thing (a coherent interaction model two apps
  actually follow) already exists.

## 3. Goals and non-goals

Goals:

1. A per-mode behavior-contract test matrix that a refactor can lean on.
2. Split the monolith internally with **zero public-API change** and zero
   visual change.
3. Prune dead facades; add the two missing slots; shrink `control:` escape
   hatch usage to composites only.
4. One shared form-descriptor layer so consumer/host/onboarding stop
   re-implementing form orchestration.
5. Codify the usage doctrine and the new-mode governance hook.

Non-goals:

- No visual redesign of either primitive; pixel output is expected
  UNCHANGED by Phases A–B (and by C except where new slots are adopted).
- No new row system, no per-feature primitive buckets (repo non-negotiable).
- No changes to `packages/catch_ui_lints` (editing the analyzer plugin
  crashes local `dart analyze` — repo memory; any enforcement idea ships as
  a `.mjs` check or stays doctrine).
- No public deprecation dance — this is an app repo with no external
  consumers; dead API is deleted, not deprecated.
- Phase D migrates surfaces incrementally; it does NOT block or rewrite the
  edit spec's Phase 3 (§11 has the ordering rules).

## 4. Cross-cutting rules

Rules 1–8 of the edit spec §3 apply verbatim (branch discipline, context
packs, copy pipeline, PATH export, verification, registries, Widgetbook).
Additionally:

1. Import path stability: `catch_field.dart` and `catch_section_layout.dart`
   remain the public libraries; splits use `part` files so none of the ~60
   consumer files change imports.
2. Every phase ends with the §12 gates green and a
   `docs/audit_registry/passes.jsonl` stamp; `dart tool/audit_registry.dart
   refresh` if tracked widgets are added/removed.
3. `docs/widget_catalog.md` is updated in the same PR as any API change
   (slot additions, facade deletions) — the catalog is the contract journal.

## 5. Phase A — Behavior-contract test matrix (BEFORE any refactor)

Reorganize and complete the CatchField/CatchSection tests so Phase B has a
safety net. Execution order note: this phase is first by necessity even
though Phase C/D deliver more user value.

1. Create `test/core/widgets/catch_field/` and move the CatchField-specific
   tests OUT of `test/core/catch_primitives_test.dart` into per-area files:
   `row_modes_test.dart` (read/content/nav/action/add), `toggle_test.dart`,
   `input_test.dart` (input/inputActions/select), `control_test.dart`
   (control/choices/stepper/disclosure), `lanes_test.dart`
   (trailing/support/action bar/inset+visibility scopes),
   `save_status_test.dart`. Keep `catch_field_focus_semantics_test.dart`
   and `catch_field_accordion_test.dart` where they are.
2. Fill the matrix — one test per cell that does not already exist:

   | Facade | Must-pin behaviors |
   |---|---|
   | read/content | title/body/value lanes, maxLines clamps, icon lane |
   | nav / add | chevron/plus affordance, onTap, disabled |
   | toggle | value renders, onChanged fires, null onChanged = disabled semantics, tone |
   | input | controller round-trip, validator error lane, onSubmitted, formatters, counter/support row |
   | inputActions | open/close, commit fires onSubmit, cancel restores text, saving disables |
   | select | menu opens, selection propagates, validator |
   | choices | single + multi selection, disabled, caller-owned selected set |
   | stepper | min/max clamps, formatter, semantic labels |
   | control | expanded-on-first-build, focus released on close, saving chrome (several already exist — relocate) |
   | status lane | idle→saving→saved transitions, error precedence |
   | dismiss | escape intent cancels an open editor |
3. Section: `test/core/widgets/catch_section_test.dart` — divider ownership
   (`fieldRows` owns every separator; no double dividers), `count`/
   `trailing`/`footer` slots, `containedFieldRows` inset, `first`/`lead`
   spacing, `showInternalDividers:false`.
4. Acceptance: `catch_primitives_test.dart` contains no CatchField tests and
   shrinks accordingly; `flutter test test/core` green; every named
   constructor has at least one behavior test (assert by grep in the PR
   description).

## 6. Phase B — Internal monolith split (zero API change)

Mechanical. `git diff` outside `lib/core/widgets/` + `test/` must be empty.

1. Convert `catch_field.dart` into a library with `part` files (same
   library path; class names unchanged):
   - `catch_field.dart` — enums, `CatchField` named constructors + private
     constructor, docs. Target < 1,000 lines.
   - `catch_field_state.dart` — `_CatchFieldState` shell: lifecycle,
     focus/dismiss plumbing, mode dispatch.
   - `catch_field_edit.dart` — edit/input/select build paths.
   - `catch_field_row_modes.dart` — read/nav/toggle build paths.
   - `catch_field_control.dart` — control/disclosure/choices/stepper
     internals.
   - `catch_field_lanes.dart` — the public lane/support classes
     (`CatchFieldRow`, `CatchFieldContentRow`, `CatchFieldTrailing`,
     `CatchFieldSupportRow`, `CatchFieldActionBar`,
     `CatchFieldExplicitSaveControl`, `CatchFieldDisclosureDrawer`,
     `CatchFieldSpinner`, `CatchFieldCommitButton`, `CatchFieldToggle`,
     `CatchFieldChoiceControl`).
   - `catch_field_scopes.dart` — `CatchFieldVisibilityScope`,
     `CatchFieldInsetScope`.
   State splitting mechanism: private mixins on `_CatchFieldState` per build
   path, or top-level private builder functions — whichever produces the
   smaller diff; no behavioral branching may change.
2. Consolidate the mode×parameter validity rules: one doc-comment matrix on
   the private constructor stating which parameter groups apply to which
   `CatchFieldMode`, backed by asserts gathered in one place (move existing
   scattered asserts; add the missing obvious ones, e.g. toggle callbacks on
   non-toggle modes). Asserts only — no runtime behavior change.
3. The 84-parameter private constructor MAY remain (it is private); grouping
   into per-lane config records is OPTIONAL and only if it provably keeps
   all public constructors `const`.
4. Size gates: no file in the split > 1,500 lines. Apply the same treatment
   to `catch_section_layout.dart` ONLY if it exceeds gates after Phase C
   (currently 1,074 lines — leave it).
5. Acceptance: Phase A suite green UNCHANGED (no test edits in this phase
   beyond imports), `flutter analyze`, widgetbook analyze/build green,
   `node tool/run.mjs check design:widgetbook-contract-refs` green.

## 7. Phase C — API prune, missing slots, escape-hatch audit

### 7.1 Delete dead facades

Delete `CatchField.expanding` and `CatchField.actions` (zero usages in
`lib/` AND `widgetbook/`, verified 2026-07-17) plus any private helpers only
they referenced. Update `docs/widget_catalog.md` (removal note). No
deprecation period — app repo, no external consumers.

### 7.2 Missing slots

1. `CatchField.toggle` gains:
   - `String? helperText` → renders in the existing support lane.
   - `String? badgeLabel` → renders a `CatchBadge` after the title in the
     title row (neutral tone default; `CatchBadgeTone? badgeTone` optional).
2. `CatchField.choices` gains:
   - `String? helperText` (support lane, same as input).
   - `Color? Function(T item)? itemAccent` → forwarded to
     `CatchChip.selectable(accent:)`.
3. Widgetbook: extend the primitive contract stories with the new slots;
   catalog entry in the same PR; Phase A tests extended (toggle badge/helper,
   choices accent/helper).

### 7.3 `control:` escape-hatch audit

`CatchField.control` call sites (2026-07-17): three files. Classification is
ratified as follows:

| Call site | Verdict |
|---|---|
| `lib/user_profile/presentation/widgets/inline_editor_range.dart` | KEEP — slider composite; exactly what `control:` is for |
| `lib/hosts/presentation/host_operations/host_inline_editors.dart` `HostInlineAgeRangeEditor` | KEEP — two-input composite |
| `lib/hosts/presentation/host_operations/host_inline_editors.dart` `HostInlineOptionEditor` | MIGRATE to `CatchField.choices` (with §7.2 `itemAccent` + `helperText`) **only when** its save model becomes immediate-commit — i.e., after the edit spec's Phase 3 §7.3 lands. Until then the draft-then-submit semantics justify `control:`. Leave a `// TODO(edit-spec-p3)` marker |
| `lib/onboarding/presentation/pages/running_prefs_page.dart` | AUDIT in-PR: if it renders a plain chip group with immediate semantics, migrate to `choices`; if composite, KEEP and note why |

Goal state: every remaining `control:` usage is a genuine multi-widget
composite, and the PR description lists them with one-line justifications.

## 8. Coordination corrections to companion specs

### 8.1 Insights spec

No conflicts. (Its Phase 0 localizes the analytics-kit badge defaults —
unrelated to this doc's scope; do not duplicate.)

### 8.2 Edit spec §6.2 SUPERSEDED

Edit spec §6.2 currently instructs: render recommendation levels as a body
prefix and *"Do NOT add a badge parameter to `CatchField`"*. That
instruction is **superseded by §7.2 of this doc**: once `toggle.badgeLabel`
lands, module recommendation levels ("Recommended"/"Advanced") render via
`badgeLabel`, and any body-prefix implementation is migrated. Update the
edit spec file's §6.2 text in the same PR that lands §7.2 (one line, keep
the rest).

## 9. Phase D — Shared form-descriptor layer (⚠ OWNER gate on the prototype)

The highest-leverage improvement. Generalize the consumer profile pattern
(`SelfProfileEditTabState` descriptors → `ProfileFieldRow` mapping →
inline editors) into core so consumer, host, and onboarding share one form
orchestration stack.

1. New `lib/core/forms/catch_form_descriptors.dart` (names ratified by owner
   on review of this doc):

   ```dart
   /// P = the patch type a surface commits (UpdateUserProfilePatch,
   /// UpdateClubPatch, an onboarding draft, ...).
   sealed class CatchFormRowDescriptor<P> { String get id; }
   final class CatchFormReadRow<P> ...        // read-only row
   final class CatchFormTextRow<P> ...        // inline text entry; P Function(Object?) patchForValue
   final class CatchFormSingleChoiceRow<P, T extends Labelled> ...
   final class CatchFormMultiChoiceRow<P, T extends Labelled> ...
   final class CatchFormRangeRow<P> ...
   final class CatchFormCustomRow<P> {        // escape hatch: app-specific editors
     Widget Function(BuildContext, CatchFormRowScope<P>) build;
   }
   ```

   plus a `CatchFormRowList<P>` mapper widget that owns
   `CatchFieldAccordion` wiring and a single
   `Future<bool> Function(P patch)` save delegate (per-field commit — the
   canonical save model).
2. **Prototype gate ⚠ OWNER**: first PR migrates exactly ONE consumer
   section (About You) to the descriptor layer, with zero visual diff, and
   stops for owner API review. No further migration until approved.
3. Migration order after approval: consumer profile tab fully → host club
   edit tab → onboarding pages opportunistically. Host coordination: if the
   edit spec's Phase 3 has NOT been built yet, build its spoke screens ON
   the descriptor layer; if it has, migrate them here. Do not run both
   changes on the same files concurrently.
4. The existing `SelfProfile*` descriptor classes are absorbed (deleted)
   as their surfaces migrate; consumer-specific rows (prompt slots, height)
   use `CatchFormCustomRow` rather than forcing core to know about them.
5. Acceptance per migration PR: zero visual diff (Widgetbook compare where
   stories exist), surface tests green, net-negative lines outside core.

## 10. Phase E — Doctrine and governance

1. Add to `docs/design_language.md` (composition/usage section), verbatim
   or lightly edited by owner:

   > **CatchField doctrine.** `CatchField`/`CatchSection` are the canonical
   > surface for *entering and managing data*: edit tabs, settings,
   > configuration, onboarding forms, admin-ish host tooling. They are
   > forbidden as storytelling surfaces — browse, discovery, celebration,
   > insight/scorecard moments compose expressive components
   > (polaroid, ticket, hero, stat/chart kit) instead. If a screen is
   > something a user *reads for meaning* rather than *operates*, it should
   > not be built from field rows. New `CatchField` modes or slots require a
   > `docs/widget_catalog.md` entry, a Widgetbook contract story, and a
   > Phase-A-style behavior test in the same PR.
2. `docs/widget_catalog.md`: add the doctrine cross-link and the current
   facade inventory with the §1 census (dated).
3. Enforcement stays doctrine + review for now (repo success-criteria
   principle: no vacuous gates). Revisit a `.mjs` usage check only if drift
   is actually observed in review.

## 11. Sequencing

```
Phase A  →  Phase B  →  Phase C (7.3's HostInlineOptionEditor row waits on edit-spec P3)
Phase D: prototype after C; host migration ordered against edit-spec Phase 3 (§9.3)
Phase E: any time; ideally with C so the catalog updates once
```

Conflict management: Phases A–C touch only `lib/core/widgets/` + tests +
widgetbook and are safe alongside the companion specs' feature work, EXCEPT
§7.2/§8.2 (edit spec §6.2 supersession — same PR) and §7.3 (waits on edit
spec Phase 3). Phase D is the only phase that touches feature surfaces;
follow §9.3 ordering.

## 12. Verification gates (per phase)

```sh
export PATH="$HOME/development/flutter/bin:$PATH"
flutter analyze
flutter test test/core test/user_profile test/hosts test/onboarding
node tool/run.mjs check design:widgetbook-contract-refs
node tool/run.mjs check design:widgetbook-coverage
node tool/run.mjs check design:section-headers
node tool/agent/check_agent_readiness.mjs
```

Plus widgetbook analyze/build for Phases B/C, catalog + passes.jsonl stamps
per repo rules, and for Phase B specifically: a PR note confirming
`git diff --stat` touches only `lib/core/widgets/`, `test/`, `widgetbook/`.

## 13. Confirmed healthy — do NOT "fix"

- The named-constructor facade pattern itself, and the five-mode model —
  the API is the good part; the split is internal.
- The explicit-save lane system (`CatchFieldStatus`, action bars, commit
  buttons) — it encodes the app's save philosophy; companion specs depend
  on it.
- `CatchField.defaultEmptyValueText` / `resolveEmptyValueText` l10n-aware
  empty-copy canon.
- `CatchSection`'s slot set (`title/count/trailing/footer/first/lead`,
  divider roles) and `CatchSectionList`/`CatchSectionStack` rhythm wrappers
  — recently exercised by two full redesign specs without needing changes.
- `CatchFieldAccordion` (new, already landed) and its adoption path.
- The browse-surface division of labor: Section-as-scaffolding with
  expressive components inside is CORRECT usage, not a gap.
- `catch_field_focus_semantics_test.dart` — keep as-is; Phase A moves
  tests out of the primitives catch-all, not out of this file.
- `inputActions` — one usage today but load-bearing in the edit spec's
  target save model; not a dead limb.
