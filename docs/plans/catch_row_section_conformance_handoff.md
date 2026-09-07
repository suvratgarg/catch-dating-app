---
doc_id: catch_row_section_conformance_handoff
version: 1.0.0
updated: 2026-09-07
owner: ui_elevation_initiative
status: proposed
---

# Catch UI row and section conformance handoff

This is an implementation handoff for work **after Catch UI extraction**. The
2026-09-07 request authorizes diagnosis, rules, and lint/test specifications in
this pass; it explicitly defers executable checks and primitive refactoring.
No proposed API or diagnostic below exists merely because it is named here.

Source examined: `origin/main` at
`d0a07412fcb632b3a2aff971c60a545b197cbd36`. Paths below refer to that commit.
The extraction worktree is separate, active work and was not modified or used
as proof of completed behavior. Re-resolve symbols and paths after it lands.

This temporary handoff extends the existing
[Field/Section hardening work](catch_field_section_system_spec.md), not a second
architecture. The extraction task currently claims that specification and the
durable owners. During implementation, reconcile this proposal into
[design language](../design_language.md), [app architecture](../app_architecture.md),
[widget catalog](../widget_catalog.md), the existing Field/Section specification,
and [component contracts](../../design/components/README.md). Retire this handoff
after its requirements live in those owners and executable checks.

## 1. Goal, scope, and acceptance

Make every ordinary vertical content/action row a composition of Section,
Field, and a passive content layout. Using approved components must not permit
an accidentally inset, square-cornered interaction surface, a missing row-list
header rule, or a sibling divider running underneath an avatar/icon.

Scope includes the package's field modes, row layouts, section and header
variants, page/lane geometry protocol, exports, analyzer plugin, component
contracts, package tests, and Host/Consumer adopter checks. Initial regression
surfaces are Organizer Identity, Audience People, and both Events tabs.
Person, record, host, index, roster, notification, note, timeline, send, and
vertical menu/choice rows must be classified by behavior, not by class name.

Exclusions for this pass: production edits, package extraction changes,
executable lint/test changes, golden updates, product/domain/save-policy
changes, dependency installation, deployment, and phone-build claims.

This specification is complete when each finding has an owning boundary,
concrete enforcement vehicle, failing example, positive control, and runtime
acceptance criterion. The later implementation is complete only when the
package and adopter checks enforce these criteria, obsolete bypass APIs are
removed, and actual rendered interaction states are reviewed.

## 2. Confirmed diagnosis

| Finding | Source evidence | Consequence |
|---|---|---|
| Parallel interaction owner | `CatchRowPressSurface.build` in `lib/core/widgets/catch_row_press_surface.dart` uses a rectangular `Positioned.fill` overlay constrained to its parent; it does not consume Field geometry. | A padded parent produces the forbidden inset rectangle by default. |
| Record/person bypass | `CatchRecordRow.build`, both `CatchPersonRow.build` branches, `CatchHostRow.build`, and `CatchIndexRow.build` call that surface directly. | Reusing a shared row does not enforce the Field contract. |
| Wrong Events section role | `HostEventsTimelinePage.build` in `lib/hosts/events/presentation/widgets/host_events_list.dart` uses `CatchSection.plain`; `_sectionContent` adds header, gap, and body with no header rule. `_body` uses generic divider indent zero. | The month lacks a rule and sibling separators span the icon lane. The kicker is already shared; the defect is the selected section role, not necessarily a hand-written header. |
| Header name alone is not a contract | `CatchSectionHeader` in `catch_section_header.dart` accepts typography/padding flags and does not paint a rule. Row-section headers are currently composed separately inside CatchSection. | Replacing the month label with a widget named SectionHeader would not fix ownership. Titled row sections need the strict header-plus-rule recipe. |
| Person/host/index own section work | `CatchPersonRow` exposes `divider`, `dividerInset`, and padding; `CatchHostRow` paints a top border; `CatchIndexRow` paints a bottom border. | Individual rows can add or change list separators independently of Section. |
| Field has a bypass too | `CatchFieldRow.standard/add` accept `onTap`; `CatchField._buildAdd` takes that route into `CatchRowPressSurface`. | Wrapping every row in today's Field alone is insufficient. Add must join the same interaction path. |
| Field hover is incomplete | `_buildRow` in `catch_field_row_modes.dart` observes press and focus; its `MouseRegion` has exit handling but no hover-enter tint state. | The pictured Organizer state demonstrates the desired geometry, not proof of a complete pointer-hover contract. True hover must be tested separately from touch/press/open. |
| Divider metadata is inferred unreliably | `_automaticFieldDividerInset` in `catch_section_layout.dart` only recognizes direct `CatchField` children, takes the largest leading inset, and otherwise guesses the standard icon inset. `CatchFieldLanes.divided` uses fixed `CatchDivider.fieldRow()` geometry. | Adapter wrappers and different avatar sizes lose their real text-lane position. Choosing `fieldRows` alone does not fix every case. |
| Physical coordinates leak into row rules | `_buildFieldRows` positions divider start with `left`, and legacy person dividers do likewise, although `CatchDivider` itself uses directional padding. | The outer composition can defeat RTL correctness. This is a source-level risk requiring a mirrored geometry test. |
| Paint and input extents can diverge | Field paints negative horizontal outsets in an `IgnorePointer` overlay while its gesture target remains around the padded row content. | Full-bleed paint does not prove the gutters are hit-testable. The future contract must measure both. |
| Tests encode the weaker contract | `host_operations_customers_tests.dart`, test `customer directory uses shared person-row feedback`, asserts `overlayRect == rowRect` inside `CatchPageBody`. The adapter test in `catch_section_test.dart` expects a fixed fallback inset. | Both can pass while the intended screen-edge and actual text-lane geometry is wrong. |
| Events tests miss the requested geometry | `host_events_layout_test.dart` covers wrapping, rail position, data, activation, and an inset row origin; its Past fixture has only one event. | It cannot detect an incorrect inter-event divider or highlight perimeter. Content inset is valid; using it as the highlight boundary is not. |
| Enforcement checks syntax and selected paths | `catch_ui_rules.dart` checks Field ancestry in a local AST, accepts any CatchSection constructor, and scopes relevant ownership rules to `/presentation/`; raw-control exemptions include all `/lib/core/widgets/`. | Generic sections, helper indirection, and package relocation require stronger type/ownership checks. A package-wide raw-control exemption would reproduce the problem. |

Existing `check_section_dividers.mjs` and `check_section_headers.mjs` both exited
zero with **zero high-confidence findings** on the audited SHA. They do not
prove the screenshot invariants. The divider scanner discovers `lib`, `test`,
and `widgetbook/lib`, so its discovery also needs explicit package/app coverage
after extraction. This pass did not run Flutter tests or claim runtime proof.

The direct `CatchRowPressSurface` construction search also found
`CatchButton.command`, `CatchOptionGroupItem.summary`, customer notes in
`host_customer_memory.dart`, and Sends in `host_sends_workspace.dart`. The
first two are compact controls; they need their own approved rounded feedback,
not accidental row feedback. The latter two are ordinary rows and must migrate.

## 3. Required separation of concerns

| Owner | Owns | Must not own |
|---|---|---|
| Page/lane composition | Content gutter, readable lane, shell obstruction, and explicit available interaction extent | Per-row shapes or row-specific margin compensation |
| Section | Header + header rule, divided/contained policy, outer clip/perimeter, sibling rules, grouping/rhythm, row placement | Domain callbacks or a second row recognizer |
| Field | One row interaction state machine, activation, hover/press/focus, disabled state, semantics, disclosure, control coordination; paints/hit-tests the geometry granted by Section | Sibling/header dividers or viewport calculations |
| Passive layout | Leading visual, primary/supporting text, metadata/status presentation, natural-height layout; package-derived content-lane metrics | Row callbacks, recognizers, focus nodes, hover state, interaction fills/outlines, or sibling separators |
| Feature adapter | Domain-to-semantic-data conversion, localized strings, callbacks passed to Field, stable identity keys | A replacement field shell or geometry constants |
| Form/menu/list orchestration | Save/validation/accordion, menu dismissal and roving navigation, pagination/reorder policy | A second row highlight or duplicate activation target |

The same interaction implementation serves all relevant Field modes, including
Add, person, record, navigation, action, readonly, selection, and sortable rows.
Native inputs and switches retain their own input behavior under Field's
coordinated control slots. This does not require a single giant State class:
private helpers may split rendering, input arbitration, and state transitions.

Current Field constructors accept particular title/body/leading/control slots;
they do not yet expose the general passive person/record layout contract below.
Do not attempt the migration by nesting an existing interactive PersonRow in
`action`, `leading`, or a disclosure `control` slot to satisfy a structural lint.

### 3.1 Closed content and section APIs

Preserve Field's named capability constructors. Add a **typed passive layout
contract** for their content. Person and record become layout configurations
rendered inside Field, not tappable widgets wrapped by another tappable Field.
The payload must expose package-derived leading/content/trailing lanes before
Section places separators. Do not add an unrestricted `Widget child` escape
hatch whose internals can silently become another interaction system.

Illustrative target syntax only; finalize names against extracted source:

```dart
CatchSection.fieldRows(
  title: monthLabel,
  children: [
    CatchField.nav(
      onTap: openEvent,
      child: CatchFieldLayout.record(
        leading: eventVisual,
        title: title,
        facts: facts,
      ),
    ),
  ],
);
```

Here `CatchFieldLayout` means a sealed, immutable package-owned layout payload,
not an arbitrary StatefulWidget. Person/record/index/host/menu are named layouts
or recipes of that contract. If a renderer needs rich text, introduce a typed
text/metadata slot that preserves current meaning and styling; do not flatten
rich metadata or force records into editable-value typography. Secondary
interactive actions belong to Field's explicit control/action slots, not to
the passive body. A new layout is added inside the package with contract tests.

Section row constructors accept typed Field entries (or a closed Field-entry
descriptor), including lazy builders with typed results for long lists.
Feature factories may return those entries directly; opaque adapter Widgets
must not hide lane information. Seal the public construction boundary where
Dart allows it. Generic editorial section constructors stay for non-row
content and must reject row entries. Do not create a second row-section family
or retain compatibility aliases after callers have migrated.

`CatchFieldLanes.divided` must use the same Section-owned row-group renderer,
not a second separator algorithm. `.single` is a transparent composition
adapter, not an independent scope granting default geometry; `.custom` cannot
be used to legalize an ordinary row list. If the post-extraction API cannot
express this safely, narrow/remove these bypasses in the same migration.

Remove public interaction from `CatchFieldRow` anatomy. Delete
`CatchRowPressSurface` when its final legitimate consumers migrate, or keep a
strictly private input helper used only by sanctioned control owners. An
exported rectangular press widget is not an approved exception.

## 4. Geometry and behavior rules

The user confirmed that the header rule spans the **content width**, from the
leading icon lane to the trailing content edge. Row feedback extends farther,
to the phone/page interaction edges. These are separate coordinate systems.

1. **Default row feedback:** full bleed to the nearest declared page or lane
   interaction extent. Content remains padded. In a split pane, never cross
   into the neighboring pane. A rounded inset treatment is an explicit
   whole-section policy, including when chosen by a responsive page policy.
2. **No accidental inset square:** an uncontained square band is valid only
   when it meets both interaction edges. Missing geometry context must fail
   clearly in development/tests or choose a documented safe rounded fallback;
   never silently interpret a zero outset as proof of full bleed. Production
   compositions must have a Section owner; isolated previews supply one.
3. **Contained groups:** one rounded outer perimeter and clip owned by Section.
   Internal active bands may be rectangular only within that owner. First,
   last, and single-row exterior corners inherit its clip. No local nested
   rounded frame or double border.
4. **Header:** a titled row section always owns its canonical kicker, spacing,
   and one content-width rule below it. Callers supply label/count/actions,
   not typography, rule toggles, indent, or padding. Headerless groups select
   the semantic headerless role, not `plain` to suppress required chrome.
5. **Sibling separators:** exactly N-1 for a nonempty ordinary divided group.
   Each begins at the actual primary text-lane start and ends at the trailing
   content edge; it does not underline the leading visual. No last-row rule
   unless it is a separate Section-owned boundary. Derive metrics from the
   selected layout, never an unrelated standard icon token or a type guess.
6. **Mixed layouts:** the default boundary follows the preceding row's text
   lane. If a package recipe intentionally aligns a mixed group to a common
   lane, it must move both text and separators together. The current maximum
   inset calculation without corresponding text placement is insufficient.
   Apply all start/end calculations directionally in RTL.
7. **State consistency:** hover, primary-pointer press, keyboard focus,
   selected, and open states share the chosen silhouette. Their colors,
   borders, and precedence may differ by semantic state; geometry must not
   jump. A focus ring remains visible when hover is also active. Press is
   momentary; selected/open state is persistent; readonly is not disabled.
8. **Divider interaction:** adjoining rules yield when a highlighted field
   occupies their coordinates, without double strokes, flashes, or permanently
   missing dividers on exit. Test paint through transitions, not only widget
   presence. Section owns separator visibility even if rendering is delegated.
9. **Hit and semantic extents:** the primary target includes the visible
   full-bleed band, including its gutters, within its page/lane. Independently
   actionable trailing controls retain distinct targets. A label-only body
   must not be the only clickable area beneath an edge-to-edge highlight.
10. **Activation:** one primary action per pointer/keyboard/semantic activation;
    no parent action on secondary controls, scroll/drag cancellation, disabled
    rows, or secondary-button presses. Field routes long press/context actions
    and sortable handles explicitly where needed. No duplicate tab stop around
    native text/switch controls. Row semantics preserve selected/toggled/
    expanded/unread information and meaningful labels without duplication.
11. **Reflow and virtualization:** natural-height person and record meaning
    survives 2x text scale and narrow widths. Reorder, filtering, pagination,
    and lazy recycling preserve keyed state; separators follow current sibling
    relationships without retaining stale hover/focus. Package geometry uses
    local constraints, not direct screen-size arithmetic in content layouts.

The default above extends the user's full-bleed requirement across row
families. Existing automatic split-pane rounding must be reconciled explicitly:
the safe recommendation is full bleed within each pane, with rounded treatment
selected at the section/page policy boundary when deliberately desired.

## 5. Exceptions and migration coverage

These are proposed classification rules, not a blanket exemption for anything
with a different name or anything located inside the package.

| Family | Disposition |
|---|---|
| Person/chat-preview/record/host/index, including readonly records | Field + row Section + passive layout. Chat previews are rows even though chat messages are not. |
| Notes, Sends, customer timeline entries, form response/automation/template records, application and roster entries | Same composition; preserve domain formatting and distinct secondary controls. |
| Vertical menu actions and choice lists | Same row ownership using menu/choice layout and Field semantics. Menu owner retains dismissal, traversal and grouping; a bounded menu Section supplies its clip. Avoid accidental editable-field semantics. |
| Reorderable rows | Same composition; Field's explicit handle slot delegates reorder gestures without triggering the primary action. |
| Button commands, horizontal tabs/chips/segmented controls | Dedicated button/selection primitives own their control feedback. Do not turn them into Field rows just because they internally use Flutter Row; remove their dependence on the raw rectangular row surface. |
| Inline metadata, icon/text fragments, chart labels and statistic strips | Passive composition; no extra Field around fragments already inside an owning row/card. |
| Posters, tickets, photo cards, maps, chat-message bubbles and timeline connector artwork | Retain their own approved surface/gesture contracts. A generic directory item cannot opt into this exception by renaming itself a card. |
| Skeletons | Same section/content geometry with interaction disabled and no focus or activation; not an alternate live row implementation. |

Complete direct legacy-family and raw-surface searches were run at the audited
SHA. They show consumers across Events, Audience, Forms/Applications, Inbox,
customer details/timelines, settings, chat inbox, Explore indexes, rosters,
event detail and Event Success. These are a migration starting set, **not proof
that every hand-built row in the repository has been semantically classified**.
The implementation census must also inspect raw gesture/list/tile constructions,
private adapters, return helpers, sliver builders, and package example apps.
Do not gate on names matching `*Row` or ban Flutter's passive `Row` layout.

## 6. Static enforcement specification

Use `packages/catch_ui_lints` as the analyzer owner, extend existing checks
where possible, and bind diagnostics to the existing component contracts.
These are proposed diagnostic names, not registered codes. Compiler errors
are preferred for impossible constructor combinations; lints protect legal
Dart constructions that violate ownership.

| Proposed check | Reject / report | Positive control and intended enforcement |
|---|---|---|
| `catch_row_interaction_is_field_owned` | Legacy row surface calls, row-layout `onTap`/hover/focus state, raw row recognizers outside the exact Field/control implementation owners | Field navigation/selection with passive person/record layout; a dedicated button is allowed. Sealed API + resolved-symbol analyzer rule. |
| `catch_field_layout_is_passive` | Recognizers, interactive semantics, focus targets, whole-row state paint, or sibling dividers in a registered layout renderer or passive slot dependency | Avatar, typed text/metadata/status layouts; interactive action supplied to Field's action slot. Analyze registered renderer call graph, not arbitrary widget names. |
| Extend `catch_field_requires_section_context` | Row entries in generic plain/content sections, free-floating row collections, fake FieldLanes wrappers, or a builder whose return does not establish the declared composition | Typed row-section list, typed lazy builder, and feature factory returning a closed entry. Type constraints first; resolved helper/branch checking for surviving wrappers. |
| Extend `catch_field_geometry_is_section_owned` | Consumer construction/import of renderer scopes, private section surfaces, per-row radius/outset/plane overrides, or raw clipping around a field list | Whole-section semantic policy; page publishes its extent using public composition API. Check all package consumers, not just `/presentation/`. |
| Extend `catch_field_divider_is_section_owned` | Row-owned borders/separators, caller-provided sibling indent/presence, manually interleaved row separators | Canonical Section renderer and true non-row separator such as a pane boundary. Resolve the role/context; don't outlaw every border in a layout (e.g. avatar ring). |
| Strengthen row-section header check | A typed row collection under `CatchSection.plain`, separately painted label/rule chrome, or disabling a required header rule | Titled row Section with semantic header data; headerless row role; editorial non-row title. Compiler + analyzer; existing regex scanner stays advisory for unknown cases. |
| Package boundary/API check | Public legacy interaction shell; private imports through export chains; raw width/radius/divider knobs returning to row/layout APIs; new unclassified interactive list family | Closed facade, approved control owners, typed layouts. Check exported resolved API and compile fixtures in an independent consumer package. |

### 6.1 Analyzer implementation requirements

- Resolve declaration identity (library URI + element + constructor), including
  prefixed imports, exports, aliases, constructor tear-offs, and redirecting
  factories. Do not recognize only a spelling such as `CatchField`.
- Inspect each supported helper/builder/conditional return path; a valid sibling
  branch must not mask an invalid branch. Do not treat a local AST ancestor as
  proof of the runtime widget tree. Use a closed typed-entry API to avoid
  arbitrary cross-widget ancestry inference wherever possible.
- Unknown/dynamic construction at a protected row boundary is a diagnostic
  requiring a typed adapter, not success. Do not claim general proof of
  arbitrary Dart runtime layout or arbitrary custom painters through a lint.
  Unclassified raw interaction candidates require explicit review and a
  component contract before being considered conformant.
- Package-internal raw input access is limited to exact semantic owners,
  including their Dart `part` units. `/lib/core/widgets/`, `/packages/`,
  `/presentation/`, or a convenient filename is not an ownership exception.
- Discover installable Host/Consumer apps, shared app code, extracted package,
  its example, and Widgetbook via package graph/source roots. Package renderers
  get ownership checks even if general feature rules intentionally exclude them.
- Expected-invalid fixtures are isolated from shipping/example code. Probe
  tests assert diagnostic code **and location/count**, include valid controls,
  fail if source discovery scans zero intended files, and prove removal of a
  registration/owner mapping makes the suite fail.
- Reuse component contract enforcement declarations and generated expectations;
  do not add a second compliance registry. Waivers, if unavoidable during staged
  migration, name exact symbols/paths, owner, reason, and expiry. Zero new debt;
  remove waived legacy APIs and their waivers at migration completion.

### 6.2 Required lint fixtures

For each applicable rule include direct construction, import prefix, re-export,
alias, helper return, conditional valid/invalid branches, builder closure,
constructor tear-off, and declaration in a relocated external package.
Include two regressions verbatim in intent: a Record layout in a plain section,
and a Person layout wrapped in the old press surface inside a padded page.
Also include a row-owned `Border(bottom: ...)`, a raw hover recognizer hidden in
a passive helper, a Field Add bypass, a direct internal import, and a custom
class named like an approved primitive. Valid controls include Field-owned
secondary buttons, passive nested Flutter Rows, menu traversal around shared
fields, avatar borders, and a non-row pane separator.

## 7. Runtime and visual test specification

Package tests must run in a minimal Flutter consumer with no Catch application,
Riverpod, Firebase, app router, or app-only localization dependency. App tests
then prove real route adoption. Do not substitute a passing package suite for
testing a screen that could still bypass the package.

| Test family | Setup/action | Required assertions |
|---|---|---|
| Three-screen regression | Production Organizer Identity, Audience People, Events Upcoming/Past; deterministic data with 3 rows and a month title; padded phone page | Equal declared full-bleed feedback edges for each family; title rule spans content width; sibling rules begin at actual text; callbacks fire once. |
| Interaction matrix | Plain/person/record/index/host/menu/Add/toggle/input/sortable layouts; idle, hover enter/exit, primary down/up/cancel, focus, selected/open, disabled | Chosen shape consistent; correct state precedence; true mouse hover changes tint without pressing; disabled does not activate; no sticky state after rebuild/unmount. |
| Extent and input | Full-bleed page, padded page, capped readable lane, split pane, sheet/menu; tap and hover in both gutters and near content | Overlay paint, primary hit region, and semantic bounds respect the declared extent; lane boundaries never crossed; content gutter unchanged. |
| Rounded/contained | Explicit rounded inset section; contained single/first/middle/last rows | Rounded inset corners; single outer clip; no square exterior corner or doubled frame; internal bands bounded by clip. Check painted corner pixels, not just decoration properties. |
| Divider geometry | No leading, icon, avatar, variable leading sizes, mixed layouts, typed feature factories, lazy builder; LTR and RTL | N-1 rules; direction-aware text start; trailing content edge; no icon underline; header full content width; no fallback inset when layout metadata is unavailable. |
| Transition paint | Press/open/focus/hover transitions with adjacent rows, theme changes and reduced motion | Adjoining separators yield/restore as specified; no second stroke or transparent flash; compare intermediate frames and settled state. |
| Nested controls | Trailing message button, menu action, toggle, input clear/submit, reorder handle | Secondary action only, no primary tint/activation from excluded target; expected focus order; no duplicate native input target. |
| Semantics | Keyboard and semantic activation on navigation, readonly, disabled, selection, toggle, disclosure and unread chat | Exactly one primary semantic action where applicable; correct state/label; native input semantics retained; keyboard focus ring visible. |
| Responsive content | 320/390 logical-pixel widths, capped wide lane, two panes; scales 1.0/1.5/2.0; long text, status and localization | Meaning/actions visible, no unintended truncation/overflow; stable lane metrics; header actions reflow; no whole-widget shrink-to-fit. |
| Dynamic list | Insert/remove/filter/reorder/page rows under stable keys; hover/focus an item before update | Focus/press does not move to a different record; removed rows clear state; correct new separators; lazy rows remain lazy. |

Run geometry/behavior cases for both light/dark themes and LTR/RTL where
direction matters. Use iOS/Android target policies for touch minima and a real
mouse pointer in hover cases. Use representative visual combinations rather
than an unbounded Cartesian golden suite; every required behavior still needs
a deterministic assertion. Goldens use production layouts and Section, never
a hand-made imitation of the row being certified.

Tests measure rendered paint bounds and actual text anchors (including the
inner divider's painted box), not only `getRect(CatchDivider)` or
`overlayRect == rowRect`. Use a one-physical-pixel tolerance only for raster
rounding, not to hide a logical gutter mismatch. Exercise edge hit tests
explicitly. Keyboard/semantic tests must not infer activation from pointer tests.

### 7.1 Mutation acceptance

The suite must fail when each of these intentional mutations is applied:

1. Restore parent-sized square overlay for an inset ordinary row.
2. Remove hover-enter handling while retaining press feedback.
3. Change the Events row section to generic plain, or omit its header rule.
4. Set sibling start to zero, substitute icon inset for avatar inset, or use
   physical left in RTL.
5. Wrap a layout in its own recognizer, or return Add to the legacy surface.
6. Remove the containing clip / restore standalone rounded bands inside it.
7. Exclude the page gutter from the primary input target while leaving paint.
8. Drop one consuming package/source root from lint discovery, or re-export a
   private geometry API.

Map each mutation to its expected compiler/lint/widget/paint-test failure;
positive controls must remain green. Do not rewrite expected goldens merely
to accept one of these failures.

## 8. Implementation order after extraction

1. **Rebase the diagnosis:** inspect the extraction's merged SHA, package
   boundaries, owner docs, exports and actual constructors. Re-run the row and
   raw-interaction census. Record unresolved classifications as migration
   work, not compliant exceptions. Confirm package paths, not remembered paths.
2. **Encode the contract:** reconcile existing owners and component contracts;
   add typed entry/layout APIs and failing isolated lint/compile fixtures.
   Define package-owned exceptions and header/interaction defaults together.
3. **Fix the package:** one Field interaction owner including hover and Add;
   passive layouts; shared Section/lane separator renderer and metrics;
   full-bleed hit geometry; private renderer access. Preserve existing input,
   accordion, validation and save behavior with focused regression tests.
4. **Prove the reference surfaces:** migrate Organizer, People and Events
   together with the three-screen geometry/hover/divider tests. Keep existing
   Events content/reflow checks, replace the inadequate People edge assertion,
   and replace adapter fallback tests with actual lane assertions.
5. **Migrate remaining row families:** feature adapters become data/config
   factories; migrate menu/choice rows and compact-control legacy dependencies;
   handle readonly, secondary actions and long lists deliberately. Remove row
   separator knobs, legacy public shells, and temporary waivers.
6. **Close enforcement:** package/API/compiler tests, analyzer probes including
   external consumer, package widget/paint tests, production route tests,
   Widgetbook review and required derived checks. Update existing generated
   enforcement/contract outputs and delete this completed handoff.

Derive the actual required checks after extraction with
`node tool/harness/verify_local.mjs --base origin/main --list`; the following
are current extension points, not a frozen future CI checklist:

- `packages/catch_ui_lints/lib/src/catch_ui_rules.dart`, its probes and
  `tool/check_catch_ui_lints.sh`;
- `tool/design/check_section_dividers.mjs`,
  `tool/design/check_section_headers.mjs`, component enforcement coverage and
  `tool/design/generate_field_inventory.mjs`;
- `test/core/widgets/catch_section_test.dart`,
  `test/core/widgets/catch_field/lanes_test.dart`,
  `test/core/widgets/catch_responsive_section_page_test.dart`, person/index
  tests, `test/hosts/host_events_layout_test.dart`, and
  `test/hosts/host_operations_customers_tests.dart`;
- existing production geometry/primitive Widgetbook stories, relocated to the
  package ownership selected by extraction.

Do not run multiple Flutter analyzer/test processes concurrently. A green
source proposal, merged package, hosted CI, and installed phone behavior are
distinct evidence states; report them separately.
