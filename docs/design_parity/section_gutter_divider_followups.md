---
doc_id: section_gutter_divider_followups
version: 1.0.0
updated: 2026-07-04
owner: design_parity_review
status: ready-for-implementation
---

# Section / Gutter / Divider Follow-ups — Implementation Spec

Repo: `/Users/suvratgarg/Development/catch-dating-app/catch_dating_app`

This spec is the review-approved follow-up batch to the 2026-07-04 gutter and
section-ownership work (commits `13c59c95b`, `da174c1d6`, `3dc879be1`,
`8391daa40`, `ebb5ff4e2`, `f6dd76853`, `918297d5a`, `ab3041649`). All design
decisions below are already made — do not re-litigate them; escalate in the
receipt only where this spec says to.

## Required workflow

1. `git status --short` first; preserve unrelated dirty work. Read `AGENTS.md`.
2. Work the items in order; commit per item (or per coherent pair) with a
   short imperative subject.
3. Never edit `packages/catch_ui_lints` in this pass (local plugin recompile
   crashes `dart analyze`); enforcement changes here are `.mjs` scanner
   changes only.
4. After each item: focused `flutter test` for the touched surfaces,
   `flutter analyze --no-fatal-infos` on touched files, and the named
   scanners. Run Flutter test/analyze invocations sequentially, never in
   parallel.
5. Finish the batch with: full `flutter analyze --no-fatal-infos` (must exit
   clean — fixtures under `tool/design/fixtures/**` are analyzer-excluded as
   of `ab3041649`), `node tool/agent/check_agent_readiness.mjs` (must stay
   100/100), a `docs/widget_catalog.md` changelog entry + version bump +
   `docs/audit_registry/doc_versions.json` update for any widget contract
   change, and one pass stamp in `docs/audit_registry/passes.jsonl`.
6. Widget contract changes need widgetbook coverage kept current for the
   changed types. Hand-edit `@UseCase` blocks (never regex across them), then
   regenerate.

---

## Item 1 — Extend the flush contract to contained sections

**Decision.** Containers own gutters; rows are flush inside them. This
already holds for `CatchSection.divided` (via `CatchFieldInsetScope`). It
must also hold for `CatchSection.contained`: the focus surface pads
`CatchSpacing.s4`, and any `CatchField` inside additionally self-insets
`s4`, producing a 32pt interior text gutter. Example live today:
`HostTeamManagementSection` renders `CatchField.input` rows inside
`CatchSection.contained`.

**Change.** In `lib/core/widgets/catch_section_layout.dart`,
`_buildContained` wraps its section content in
`CatchFieldInsetScope(flush: true, child: ...)` — the scope goes INSIDE
`CatchSectionFocusSurface` (the surface padding is the owned gutter), around
the same subtree that `_sectionContent(...)` returns. Extend the existing
`show CatchFieldInsetScope` import clause if needed. Do NOT touch
`CatchSection.plain` — plain sections have no owned gutter; their parents
decide.

**Accepted visual change (review-approved).** Field rows inside every
contained section lose their 16pt self-inset; row content, trailing
affordances, and any internal dividers align to the card's `s4` content
padding. Survey the affected surfaces before/after (grep
`CatchSection.contained(` call sites and check which contain `CatchField`)
and list them in the receipt.

**Tests.**
- Add a primitive test in `test/core/catch_primitives_test.dart` mirroring
  the existing `CatchSection.divided renders field rows flush with
  lane-aligned dividers` test: a `CatchField.read(icon:, title:, valueText:)`
  inside `CatchSection.contained` must have its leading icon flush with the
  surface's content-padding edge and its trailing value on the opposite
  content edge (assert relationships, not absolute pixels).
- Re-run and, if geometry assertions exist, update
  `test/hosts/host_team_management_section_test.dart` and the club-detail
  contact tests.

**Acceptance.** Primitive test green; no contained call site compensates
with ad-hoc negative padding or per-instantiation overrides; catalog entry
notes that `contained` now publishes the flush scope.

---

## Item 2 — Migrate raw dividers to `CatchDivider`

**Decision.** `CatchDivider.section` / `CatchDivider.fieldRow`
(`lib/core/widgets/catch_divider.dart`) are the only two divider treatments.
The `design:section-dividers` inventory (28 medium, 7 low at time of
writing) is the worklist: `node tool/run.mjs check design:section-dividers`.

**Per-site rule (apply mechanically, in this order):**
1. Separator between field rows, list rows, tiles, or other repeated
   same-kind siblings → `CatchDivider.fieldRow` (keeps the
   `fieldRowTextLaneInset` indent default when the rows are icon-led; pass
   `indent: 0` when the rows have no leading slot).
2. Separator between blocks/sections/regions → `CatchDivider.section`.
3. Divider on a dark/editorial overlay surface, or one whose color is a
   semantic accent rather than `t.line`-derived → KEEP the existing widget
   unchanged and record it in the receipt with one line of reasoning. Do not
   force these into the roles.
4. Hairlines that are not dividers (chart strokes, ticket perforations,
   skeleton bones, progress tracks) are out of scope — leave them.

Replacement covers raw `Divider(...)`, hand-rolled
`ColoredBox(color: line…, child: SizedBox(height: 1))`, and
`DecoratedBox(border: Border(top: ...))` used as row/section separators.
Where an existing divider's alpha differs from the role's
(`t.line` full vs `fieldRowDivider` alpha), the role's treatment WINS — this
standardization is review-approved; note each such visual delta in the
receipt.

**Acceptance.** `design:section-dividers` medium count drops to 0 or every
survivor is a rule-3 keep listed in the receipt; no new raw dividers in
touched files; visual deltas enumerated.

---

## Item 3 — Burn down the 6 HIGH screen-gutter findings

**Decision.** Horizontal screen padding in presentation code must come from
a `CatchInsets` role (or a role + `copyWith` for vertical-only deviations).
Never spell a page gutter as `CatchSpacing.s5` or raw `screenPx` inside
`EdgeInsets` literals in features.

**Worklist.** `node tool/design/check_screen_gutters.mjs --summary --max 47`
— fix the 6 HIGH findings:

- `lib/swipes/presentation/filters_screen.dart:197, 247, 275, 292` — each is
  `EdgeInsets.fromLTRB(s5, s2|s3, s5, s5)`. Map to the `CatchInsets` role
  with the same values if one exists (check `pageBodyTight`,
  `pageBodyCompact`, etc.); otherwise use
  `CatchInsets.pageBody.copyWith(top: CatchSpacing.<x>, bottom:
  CatchSpacing.<y>)`. If the same LTRB tuple recurs 3+ times across the
  file, define ONE local `const` derived from the role via `copyWith` (a
  derivation, not new raw numbers).
- `lib/swipes/shared/profile_surface/catch_profile_view.dart:87` and
  `lib/swipes/shared/profile_surface/profile_surface.dart:124` — both
  `fromLTRB(s5, s7, s5, bottomPadding)` with a dynamic bottom:
  `CatchInsets.pageBody.copyWith(top: CatchSpacing.s7, bottom:
  bottomPadding)`.

If a genuinely recurring rhythm has no role, propose a new
`CatchInsets.pageBody*` role in the receipt — do not mint one silently.

**Acceptance.** Scanner HIGH count = 0; MEDIUM/LOW inventory may remain
(tracked debt — the ratchet decision stays with the owner and is out of
scope). Pixel-identical rendering (these are respellings, not layout
changes) — assert via existing screen tests where they exist.

---

## Item 4 — Token hygiene crumbs

1. `lib/core/widgets/catch_horizontal_rail.dart` and
   `lib/core/widgets/catch_vertical_section.dart`: every horizontal
   `CatchSpacing.s5` that means "the app screen gutter" (defaults, literals,
   and the doc comments) becomes `CatchSpacing.screenPx`. Visual noop; these
   core widgets legitimately own gutters, they just spell the token wrong.
2. `CatchFieldTrailing.valueText` in `lib/core/widgets/catch_field.dart`
   caps at raw `maxWidth: 160`. Add ONE token —
   `CatchLayout.fieldTrailingValueMaxWidth = 160.0` — next to the other
   field-row layout tokens in `lib/core/theme/catch_tokens.dart`, and use
   it. (Token addition explicitly sanctioned here.) Update the primitives
   test that asserts `lessThanOrEqualTo(160)` to reference the token.

**Acceptance.** No `s5`-spelled gutters remain in those two files; no raw
160 in catch_field.dart; analyzer clean.

---

## Item 5 — Section-header scanner: flag-proliferation inventory

**Decision.** `showHeader:`/`showTitle:` content-only flags are fine at the
current count; at 3+ distinct widgets the pattern should flip to extracted
content-only child widgets. Make the scanner surface this so the flip moment
is visible instead of remembered.

**Change.** Extend `tool/design/check_section_headers.mjs` with a LOW-level
inventory: count distinct widget classes declaring a `showHeader` or
`showTitle` boolean parameter, list them in `--summary` output, and print an
advisory line when the count is ≥ 3 (advisory only — never a failure).
Extend `tool/design/check_section_headers.test.mjs` with a fixture-driven
case for the new inventory. Keep the check's exit-code semantics unchanged.

**Acceptance.** Scanner tests pass; `node tool/run.mjs check
design:section-headers` output includes the flag inventory; manifest entry
untouched (same id/category).

---

## Stretch (only if the batch above lands clean) — enum-editor expanded header

The prompt editor now hides the header `body` while expanded (single source
of truth in the control; `918297d5a`). The single/multi choice editors in
`lib/user_profile/presentation/widgets/inline_editor_choice.dart` may still
render the joined value in the header while the control shows the selected
chips. FIRST verify against the rendered tree/tests (see
`test/profile/profile_widgets_test.dart` `multi-choice selected chips move
into the row value slot` — the duplication may already be handled). If, and
only if, the header body still renders alongside the selected-chip display
when expanded, apply the prompt pattern: `body: null` while expanded,
collapsed behavior unchanged, update the affected tests, and note the visual
delta in the receipt. If the current rendering is already single-source,
record "no change needed" and stop.

---

## Completion checklist

- [ ] Item 1: contained flush scope + primitive test + surface survey
- [ ] Item 2: divider migration, scanner medium count 0 (or receipted keeps)
- [ ] Item 3: gutter HIGH count 0
- [ ] Item 4: token respellings + `fieldTrailingValueMaxWidth`
- [ ] Item 5: scanner flag inventory + tests
- [ ] Catalog changelog + version + doc_versions; passes.jsonl stamp
- [ ] Full analyze clean; readiness 100/100; all named scanners green
