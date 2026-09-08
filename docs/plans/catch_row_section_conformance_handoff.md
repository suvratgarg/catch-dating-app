---
doc_id: catch_row_section_conformance_handoff
version: 2.1.0
updated: 2026-09-08
owner: ui_elevation_initiative
status: proposed
---

# Catch UI composition and Host screen implementation handoff

## 0. Start here

This is the single handoff for the Events, Audience, Organizer, Today, and
Messaging composition work discussed in **Audit hover state regressions**.
It also incorporates the accepted decisions from **Define deterministic UI
primitives**. It replaces the narrower 2026-09-07 version of this same handoff;
do not implement the two versions as separate projects.

**This pass authorizes documentation only.** No API, lint, test, layout, or
product change is implemented by its appearance in this document. Dart examples
are proposed API sketches, not compilable claims about the current package.
Production refactoring, executable checks, golden updates and deployment await
the subsequent implementation task.

Source baseline: `6030865f9c95a7513fc71d7d72e79782e506fd57`, refreshed from
`origin/main` on 2026-09-08. **Phase 3 extraction has already merged at this
baseline** (`Extract the shared UI package (Phase 3)`, PR #366). The earlier
screen audit used `d0a07412fcb632b3a2aff971c60a545b197cbd36`. This revision uses
the extracted paths and rechecks the relevant compositions; extraction is not
proof of conformance to the new contracts below. Recheck later extraction
follow-ups and active work before implementation.

Handoff distribution branch: `codex/catch-ui-composition-handoff-20260908`.
If this document is not yet on main, retrieve this file from that branch; the
implementation branch must still start from freshly fetched main. The handoff
does not depend on the original task's local worktree or temporary audit files.

This is a temporary implementation plan under the existing
[UI-system program](ui_system_blueprint_and_conformance_audit.md) and
[Field/Section hardening specification](catch_field_section_system_spec.md).
Durable decisions belong in [design language](../design_language.md),
[app architecture](../app_architecture.md), [widget catalog](../widget_catalog.md),
and the existing [component contracts](../../design/components/README.md).
Move the implemented requirements into those owners and executable checks,
then retire this handoff. Do not create a second architecture or enforcement
registry. Generated feature READMEs are discovery aids, not editing targets.

Read §§1–5 for the contract and API; §§6–10 for the five screens; §§11–14 for
enforcement, verification, delivery and the ready-to-send task prompt.

### Decision status

| Status | Meaning in this document |
|---|---|
| Agreed | Direct user direction: full-bleed default, rounded deliberate inset treatment, content-width header rule, ordinary rows through Section/Field, passive person/record layouts, attached dependent area, two dependent levels inline, no automatic modal, current-performance-first Insights, and Messaging grouped by person across channels. |
| Required consequence | Ownership and verification constraints needed to make the agreed behavior hold, such as no second row recognizer and testing painted and hit bounds separately. |
| Recommended | Proposed API names, screen reading order beyond agreed cases, control recipes and migration structure. Validate against the reference cases before making them permanent. |
| To validate | Specific remaining visual/product questions in §13. They do not reopen agreed decisions or block unrelated foundations. |

## 1. Problem, outcome and scope

### Problem statement

Equivalent ordinary rows do not share an enforceable composition contract.
Several public widgets independently own row interaction, padding, borders or
dividers. Approved components can therefore compose into an inset square
highlight, a missing section-header rule, or a divider underneath an avatar.
Refactors can retain valid Dart and passing tests while changing this geometry.

There is also a decision problem: the system often describes several legal
compositions without determining which should win for a particular task. Tabs,
filters, stored choices, commands, facts and dependent configuration can look
similar despite different semantics. Passing a structural test cannot choose a
good reading order or establish visual quality.

### Intended outcome

Developers supply meaning, values, identity, relationships and actions.
Catch UI supplies consistent composition, geometry, typography, interaction and
accessible state. The normal API cannot express the known invalid row shapes;
remaining bypasses fail targeted checks. A feature author can find the correct
recipe and production example without reading the entire design corpus.

Scope: shared row/section/form/page/control APIs, package boundaries, five Host
root-screen compositions and relevant child presentation seams, deterministic
lint/test specifications, visual acceptance, and migration/deletion criteria.
Events and Audience collections, Organizer editing/analytics, Today operational
states and Messaging scope/threads are reference configurations, not exceptions.
Event Policy is the dependency stress case; Consumer Activity and Profile are
cross-product visual references, not templates to copy indiscriminately.

Excluded from automatic implementation: new palette/fonts, business policy or
permission changes, new sending capabilities/channels, a universal schema-to-UI engine,
new analytics, speculative onboarding, release/deploy changes, and a wholesale
rewrite of every feature controller. Preserve unrelated work and concurrent
extraction changes. Source tests, merged CI, distribution and installed device
behavior are separate evidence states.

### Source-backed causes

| Cause | Current/source evidence | Required correction |
|---|---|---|
| Multiple interaction owners | `packages/catch_ui/lib/src/components/catch_record_row.dart`, `catch_person_row.dart` delegate to `src/primitives/catch_row_press_surface.dart`. The surface paints a rectangular parent-sized overlay. | Layouts become passive; Field owns row interaction. |
| Wrong section role | `lib/hosts/events/presentation/widgets/host_events_list.dart`, `HostEventsTimelinePage`, still constructs `CatchSection.plain` around `HostEventLifecycleRow`/`CatchRecordRow`. | Typed row sections supply header rule and text-lane sibling separators. The month label already uses shared section infrastructure; a different label widget alone cannot fix it. |
| Field bypass and incomplete hover | The original audit found Add delegating through legacy row anatomy and a press/focus path without hover-enter tint. Those families moved into package Field renderers. | Audit every extracted mode, including Add, using the same interaction test matrix; do not assume merely wrapping the old rows in today's Field is enough. |
| Geometry inferred through widget shape | Current section/lane rendering has used direct-child type inspection, fallback icon insets, and separate single/divided lane wrappers. Form and feature adapters obscure actual text lanes. | Typed entries expose package-derived layout metrics independent of wrapper shape. |
| Paint can exceed input | Original Field overlays paint horizontal outsets around locally bounded gesture content. | Test both visible extent and edge activation; changing only the overlay is insufficient. |
| Checks certify weaker facts | The 2026-09-07 header/divider scanners returned zero high-confidence findings; the People feedback test accepted a row-local overlay. | Replace weak expectations with production geometry assertions and negative/mutation fixtures. Re-run after relocation; these historical results are not current test results. |
| Meaning is lost in generic props | `title/body/valueText`, arbitrary `child/children`, `control`, and styling flags accept unrelated semantic roles. | Named capabilities and typed content roles; eliminate replacement-row escape hatches. |

The source audit is not fresh visual validation of Today or Messaging. Their
font/control findings below identify selected code roles and composition; new
production captures remain an implementation acceptance requirement.

## 2. Semantic decision rules

Decide in this order: **task and information role → scope and relationships →
interaction and commit behavior → grouping and disclosure → containment and
width → package-owned typography and adaptive geometry**. When choices conflict,
preserve meaning and operability, then task hierarchy, then visual defaults.
Reflow may not change selection cardinality, save policy or available actions.

| Use case | Default recipe | Boundary / counterexample |
|---|---|---|
| Peer content views | Tabs bound to stable view IDs and panels | A stored admission setting is not a tab; pager mechanics are optional. |
| Restrict current results | Filter controls beside the affected results | A link to a child route is a navigation action, not a permanently unselected filter. |
| One short stored choice | Single-choice Field; inline alternatives if useful and legible | Two alternatives alone do not imply on/off semantics. |
| Explained alternatives | Option list/card presentation with each explanation attached | Do not expose only the selected option's explanation. |
| Large/searchable choice set | Picker with selected-value summary, search and loading/retry states | Do not choose dropdown solely from an arbitrary option-count threshold. |
| Independent on/off state | Toggle Field with concise operative label | A switch does not mean its draft was already saved. |
| Several independent values | Multiple-choice Field or terse checkable chips | Selected values remain a set; no scalar semantics hidden behind chips. |
| Ordinary record/conversation/attention entry | Field + passive layout | A directory entry cannot claim a card exception by its class name. |
| Scalar editor attribute | Label/value layout + declared editor | Explanatory prose is not the primary value. |
| Supporting content disclosure | Disclosure Field + expanded content slot | No form-validation exemption needed for a pure disclosure. |
| Metric | Value, label, period/scope, comparison, quality | A passive number does not automatically earn a card. |
| Command | Button or action menu, scoped to screen/section/row | A selector must preserve selected identity; command menus need not. |
| Repeated expressive material | Existing ticket/poster/photo/chat-message component | Preserve its own contract; do not flatten all material into Fields. |

Containment describes a meaningful unit or independent task. Full bleed
describes the reach of interaction/background/media. These are separate
decisions; full bleed does not remove text gutters. Primary information and
actions must survive narrow widths and large text. Secondary context may
condense only if its meaning remains available. Avoid forced equal-height
cards, permanently two-column metric grids, and one-line critical labels.

### Text roles

- Record/person/conversation subjects use readable title/name roles; supporting
  prose and message previews remain readable text; timestamps/provenance are
  secondary metadata.
- Editable attributes use a label/value hierarchy; explanation uses supporting
  text, never a value role merely because a prop accepts it.
- Section kickers may use the canonical mono role. Event selectors, action
  labels and message previews are not kickers. Do not turn them into uppercase
  mono headings or use an activity accent to suggest navigation importance.
- Preserve the existing brand font system. The defect may be the selected role,
  weight, casing or truncation, not an incorrect font file. Diagnose that
  distinction before changing typography foundations.

## 3. Ownership and geometry contract

| Owner | Owns | Must not own |
|---|---|---|
| Feature/controller | Domain values, permissions, queries, routes, mutations, schema-to-constraint adapters | Package renderers or local row shapes |
| Shell | Global destinations, safe area, keyboard/overlay obstruction and persistent global context | Feature filters, row insets or data-state cards |
| Page/pane | Scroll owner, readable bounds, interaction bounds, responsive pane layout and restoration | Per-row radius/outset compensation |
| Collection coordinator | Query state, independent results, pagination and stable item identity | A second row surface |
| Form coordinator | Draft/commit/validation/accordion/dependency state and reconciliation | Section clipping or hover painting |
| Section | Header+rule, content/row role, perimeter, hierarchy, sibling rules and rhythm | Primary record actions |
| Field | One primary interaction/state/semantics owner, focus, expansion and secondary action coordination | Sibling rules or viewport measurements |
| Passive layout | Leading visual, primary/supporting content, metadata/status and intrinsic lane metrics | Row callbacks, recognizers, focus targets or interaction fills |
| Editor/specialised control | Native text/choice/range/media/chart mechanics | Replacement Field/Section chrome |

### Non-negotiable geometry

1. Ordinary row feedback defaults to the nearest page/pane interaction edges.
   Content remains inset; a readable-width constraint does not silently narrow
   the interaction surface. Split-pane rows never cross into the detail pane.
2. Deliberately inset standalone feedback is rounded. Missing geometry context
   must fail clearly in development/tests or use a documented safe rounded
   fallback; zero outsets are not proof of full bleed.
3. Contained/dependent groups own one rounded exterior and clip. Internal
   rectangular bands are valid only within that perimeter; there is no separate
   inset square interactive rectangle. Individual fields cannot choose radii.
4. Titled row sections always render one canonical header rule across content
   width, including the leading visual lane. Headerless is a semantic role,
   not a `plain` escape hatch. Caller supplies title/count/action data.
5. Ordinary divided groups have `max(N-1, 0)` sibling separator positions.
   All are visible at rest when no adjacent row is active. Each starts at the
   preceding row's actual text lane and ends at the trailing content edge.
   A common-lane recipe must align text and rules together. No icon/avatar
   underlining, last-row rule or guessed standard inset. Use directional axes.
6. Hover, press, keyboard focus, selected, open, saving and disabled are distinct
   states with a shared chosen silhouette. Preserve visible focus under hover.
   Read-only is not disabled and does not imply an activation callback.
7. Section owns suppression/restoration under the explicit transition policy
   below. It reserves rule geometry during transitions; hiding a stroke cannot
   move content. Header rules and the outer perimeter are separate roles.
8. Paint, primary hit region and semantics use the granted interaction extent,
   including gutters. Explicit secondary controls have distinct targets and
   never trigger primary activation. Drag/scroll cancellation and disabled
   input do not activate the row; right-click is not a primary tap.
9. Native inputs retain their proper semantics; do not add a duplicate tab stop
   or intercept text selection with a whole-row gesture wrapper.
10. Stable keys follow records through filtering, insertion, paging and reorder.
    Keyboard focus/selection follow identity; hover is recomputed from current
    pointer geometry after layout. A pressed gesture cannot retarget another
    record through index reuse; cancel if its target is removed or invalidated.
    Lazy row sections remain lazy rather than becoming one giant Column.

Recommended deterministic sibling-rule transition policy: a row is active for
this purpose while hovered, primary-pressed, primary-focused, selected or
expanded. Saving/error/disabled status alone does not activate it. The package
resolves these states, not a caller-provided divider flag. Let `a(i)` be the
row's normalized active transition progress. Separator `(i, i+1)` has opacity
`1 - max(a(i), a(i+1))`: either active neighbor suppresses it, and it returns
only as both settle inactive. Use the existing motion/reduced-motion policy;
never remove its layout space. A section-header rule or containing outline is
not a sibling rule and remains visible. This is a proposed motion detail to
validate in captures, with a precise automated oracle if adopted; change this
one owner contract and its tests together if review selects a different policy.

Current automatic split-pane rounding is a deliberate migration point: this
proposal follows the user's full-bleed default within each pane, with inset
rounding selected explicitly by a whole-section presentation recipe.

### Dependency hierarchy

Reuse/reconcile `CatchFormDependencies` from checkpoint
`c5434f42dde36dfc4ba972fe717541f22cdeae22` of **Define deterministic UI
primitives** (task `01a0721a-e894-7553-94e5-a5c62e74cdab`). It has stable IDs, one
visual parent, additional prerequisites, iterative reference/cycle evaluation,
applicability and two dependent edges per presented region. Its
`CatchSection.dependentFieldRows` prototype and test history are groundwork,
not accepted production visuals. This checkpoint is separate from the extracted
package at the baseline; inspect/port its relevant changes, not the old branch
wholesale. Retrieve with `git show <checkpoint>:<path>` if its local worktree is
absent. Essential decisions are reproduced here; local image files are optional
review aids, not a handoff dependency.

The controlling choice and dependent configuration share one perimeter, with
an attached subtle tint, one gutter and no recursively deepening indentation,
shade or font reduction. Equal dividers alone imply peers, not dependency.
Logical depth can be arbitrary finite depth; visible inline depth is two
dependent levels. Beyond that the feature explicitly supplies continuation or
a coherent task step, editable ancestor summaries and return/error navigation.
The renderer never invents a modal. Declaration alone does not implement a
continuation; a declared boundary without a renderer/route must fail validation.

Collapsed active values remain applicable and validated. Inactive drafts can
be retained only according to the feature contract and must not be submitted
merely because retained. Reopening revalidates against current prerequisites;
ancestor changes apply declared reset/retention rules. Active descendant errors
reveal their path. Closing a focused branch returns focus to its controller;
opening does not arbitrarily move focus. Explain unfamiliar quantities with
units and examples derived from actual domain policy, such as extra charge
versus total price.

## 4. Proposed public API and naming decisions

### Design rules

Preserve established names when they describe the real responsibility. Rename
where a name confuses a data/interaction role or conceals duplicate ownership.
Do not rename everything simply because it moved packages. Preserve generic
choice typing, const construction where possible, stable widget keys, existing
localization/constraint injection and the recently extracted package boundary.

Prefer named capability constructors over a universal bag of booleans. Slot
names describe information, not an arbitrary physical lane. Rendering details
stay private. `CatchField` remains the one keyed row identity, with private
render/state helpers; passive layouts are immutable configuration values.

| Current | Recommended target | Reason / migration |
|---|---|---|
| `CatchField` | Keep | Canonical row interaction owner; not limited to editable scalar values. |
| `.nav(onTap:)` | `.navigate(onActivate:)` | Full word; callback covers pointer, keyboard and semantic activation. Keep `onPressed` for actual buttons. |
| `.read` | Keep `.read(content:)` | Passive field semantics, not a disabled navigable row. |
| `.action` | Keep capability; use `onActivate` | A command has no inferred navigation chevron. |
| `CatchRecordRow`, `CatchPersonRow` | `CatchRecordLayout`, `CatchPersonLayout` | Immutable passive content under Field, with no row gestures/dividers. |
| `CatchPersonChatLayout`; implicit `lastMessage != null` chat mode | `CatchConversationLayout` with explicit preview/activity data | A conversation remains a conversation before its first message; person identity and conversation activity are different roles. |
| Host/index/conversation row variants | Named typed layouts or compositions over those layouts | New layout only for a real content contract; domain adapters stay in the app. |
| `CatchField.content` and overloaded `title/body/valueText` | Typed `content` layout | Separate attribute `label/value/supportingText` from record `title/metadata/facts`; no ambiguous aliases. |
| `CatchFieldValueContent` | `CatchValueLayout` when adopting the passive layout contract | Label/current value/supporting text for an attribute; shares the layout vocabulary with Record/Person/Conversation. |
| `.control` used for non-form reveal | `.disclosure(content:, expandedContent:, isExpanded:, onExpandedChanged:)` | Explicit reveal semantics without a validation-contract exemption. |
| `input` vs `inputActions`, commit booleans | Typed editor/form commit policy | Preserve the behavior during migration; don't collapse immediate and confirmed commits into the same ambiguous signature. |
| Set-based choice API for both cardinalities | Distinct single-/multiple-choice configurations | `T? value` versus `Set<T> values`; preserve explained/picker presentations without cardinality booleans. Final constructor names require an API fixture. |
| `CatchSection.fieldRows`, generic `.divided(children:)` for rows | `CatchSection.rows(header:, entries:)` | Typed row role, canonical default separators, optional header. |
| `.containedFieldRows` | `.containedRows(...)` | One bounded row group; no raw radius and no child-owned perimeter. |
| `.dependentFieldRows` checkpoint | `.dependentRows(...)` or named dependent-group entry | One controlling Field and attached region. Choose one integration, not parallel families. |
| Generic `.plain/.contained(child:)` | Explicit content-section recipe | Preserve real prose/media/metric uses; forbid ordinary row lists through this escape hatch. |
| `title/count/trailing` loose header props | `CatchSectionHeaderData(title:, count:, action:)` | Header anatomy and rule owned once; plural actions only when there is a real requirement. |
| `CatchFormRowList<P>` | Consider `CatchFormSection<P>` when separating its coordinator | It renders one section and binds descriptors. Defer a cosmetic rename if no responsibility changes; keep a separate coordinator for state shared across sections. |
| `CatchFormCustomRow.build -> Widget` | Typed layout/editor extension slots | Cannot replace Field with an arbitrary widget. |
| `CatchAccordionController` | Keep | Extraction already renamed the controller; do not reintroduce `CatchFieldAccordion`. |
| `CatchFieldLanes.single/divided/custom` | Internal renderer or narrow transparent adapters | Do not permit nested lane scopes to redefine the enclosing section's geometry. |
| `CatchRowPressSurface` and interactive row anatomy | Remove public use; private sanctioned input implementation only | A reusable unqualified rectangle is the original bypass. |
| Root scaffold/page scroll view/`CatchTabRail` | Keep established names | Add semantic view/selection descriptors rather than another scaffold family. |

### Prop vocabulary and type constraints

- Record: `title`, `supportingText`, `metadata`, `facts`; editable attribute:
  `label`, `value`, `supportingText`; conversation: `name`, `preview`,
  `timestamp`, typed `activity` (including exact/partial unread state), optional
  `context`. Do not flatten rich facts or
  unread states into one string to make a generic label/value row fit.
- `leading` is a closed visual descriptor (icon, avatar, image, none), not an
  arbitrary interactive widget. Its extent and text-lane metrics are resolved
  by the layout recipe. Domain activity-to-icon/color mapping stays in the app.
- Field's current save-status concept becomes `saveState`; content uses typed
  `badge/badges` for business status. `secondaryAction` denotes a real independent
  control. Do not overload `status` with both persistence and business meaning,
  reuse `action` for a badge, or accept conflicting `isLoading` and `saveState`.
- Interaction booleans follow `isEnabled/isSelected/isExpanded`; choice state
  uses `value/values` and `onChanged`. A field ID is identity, never a text label.
  Required actions plus explicit enabled state distinguish read-only from
  temporarily unavailable interactions.
- No per-row `padding`, `dividerInset`, `showDivider`, `radius`, `bleed`,
  `titleStyle`, `titleColor` or `showChevron`. Named behavior/layout roles derive
  affordances and visual treatment. Domain semantic emphasis can be typed.
- Section row construction accepts a closed Field-entry type, including lazy
  item builders with that result type. Feature factories return entries rather
  than opaque row widgets. The package obtains lane data from the entry, not
  runtime `is CatchField` tests or a walk through arbitrary widget children.
- A final Field widget may implement that closed entry interface; constructor
  typing alone cannot prove that someone placed it under a Section at runtime.
  Keep a package scope assertion and focused lints for that remaining boundary.
  Do not claim the Dart compiler proves arbitrary widget ancestry.
- Preserve injected `CatchFieldCopy` and other package copy objects, native
  `TextEditingController`/`FocusNode` ownership and disposal contracts. The sketches
  abbreviate those existing inputs; they do not authorize English defaults or
  an app-localization import into Catch UI.
- Section stack owns first/last section spacing; callers do not pass `first`.
  Specialized extensions declare a semantic component contract and typed slots,
  not an externally implementable marker interface returning arbitrary Widgets.

The extracted `catch_ui.dart` facade currently exports raw field geometry,
interaction-plane/shape, lane and press-surface mechanisms. Moving them under
`src/` has not made them private. Close public export chains, restrict external
`package:catch_ui/src/...` imports and verify an independent consumer. Internals
remain available only to exact package renderer/control owners.

### Illustrative record and person recipes

```dart
CatchSection.rows(
  header: CatchSectionHeaderData(title: monthLabel),
  entries: [
    CatchField.navigate(
      key: ValueKey(event.id),
      onActivate: () => openEvent(event.id),
      content: CatchRecordLayout(
        leading: activityVisual,
        title: event.title,
        facts: [dateAndVenue, attendance],
      ),
    ),
  ],
);

CatchSection.rows(
  entries: [
    CatchField.navigate(
      key: ValueKey(person.id),
      isSelected: person.id == selectedPersonId,
      onActivate: () => openPerson(person.id),
      content: CatchPersonLayout(
        leading: personAvatar,
        name: person.displayName,
        supportingText: attendanceSummary,
        badges: personBadges,
      ),
    ),
  ],
);
```

Content typography remains appropriate to a record/person. Reuse of Field
behavior must not turn every subject into a muted label above an editable value.

### Explicit secondary action and editor slots

```dart
CatchField.navigate(
  key: ValueKey(form.id),
  onActivate: () => openForm(form.id),
  content: CatchRecordLayout(
    leading: formVisual,
    title: form.title,
    metadata: purposeAndEditedTime,
    facts: [lifecycleAndResponseCount],
  ),
  secondaryAction: CatchFieldSecondaryAction.menu(
    label: actionsLabel,
    items: permittedFormCommands,
    onSelected: handleFormCommand,
  ),
);

CatchFormSection<UpdateOrganizerPatch>(
  header: CatchSectionHeaderData(title: identityLabel),
  coordinator: organizerForm,
  fields: [
    CatchFormTextField(
      id: OrganizerFieldId.name,
      label: organizerNameLabel,
      value: savedName,
      constraints: nameConstraints,
      patchForValue: UpdateOrganizerPatch.name,
    ),
  ],
);
```

`UpdateOrganizerPatch` above illustrates the desired app-domain name; the current
model is `UpdateClubPatch`. Do not undertake a whole data-model rename as part of
UI adoption. The form descriptor binds into a real Field and supplies editor
behavior through its coordinator. Generic package code does not import an
Organizer model, Riverpod, router, app ARB class, or generated schema.

### View, filter and picker composition

Use one list of typed view descriptors with stable IDs, labels, page factories
and optional header/search capabilities. Derive the rail and selected panel
from it. Routing remains an app adapter; local paging remains a separate
presentation adapter. A single view declaration does not require a single
`TabBarView` across unrelated route-owned workspaces.

Introduce semantic filter/choice/command facades over existing selection/menu
internals where needed. A filter offers selected value, clear/reset and result
scope; a picker represents a potentially long selected item set with search;
a command menu supplies verbs. Use local constraints and measured/localized
content to choose an anchored menu or sheet. Do not expose generic `variant`
flags that let a field choice masquerade as primary navigation.

The following is the proposed selected-scope recipe. Its option identity stays
typed; the trigger and option use the same value label. Only the feature's
`onChanged` changes the query. The picker renderer cannot dispatch a message.

```dart
CatchSection.rows(
  entries: [
    CatchField.singleChoice<InboxScopeId>(
      key: const ValueKey('inbox-scope'),
      copy: fieldCopy,
      label: scopeLabel,
      value: inbox.scopeId,
      onChanged: inbox.selectScope,
      options: scopeOptions, // stable ID, label, metadata, availability
      presentation: CatchChoicePresentation.picker(search: scopeSearch),
    ),
  ],
);
```

Optional selection uses a distinct nullable/clearable contract; a required scope
always has a valid ID. Options and the current selection come from the same app
projection, including a retained-but-unavailable selected item when needed.
Loading, retry and unknown options are explicit selection-source states, not an
empty options list. The choice factory configures its passive `CatchValueLayout`
from `label` and the selected option's label/metadata; it does not accept a second
caller-authored selected-value string. This is one authored recipe over Field,
not another interaction implementation. Scalar read/editor layouts can still
take an explicit value. Reject duplicate IDs and distinguish a retained missing
selection from permission to select an unavailable option.

For primary views, use one typed descriptor list such as
`CatchViewDefinition<EventsView>` with `id`, localized `label`, `buildPage` and
optional header capabilities. Root composition binds `views`, `selectedView` and
`onViewChanged`; its rail and pager consume that same list. Keep
`CatchRootScreenScaffold.withPrimaryRail` and `CatchTabRail` as rendering owners;
the exact binding belongs in a narrow view adapter, not a new universal screen
class. A result filter instead binds `value/onChanged` and count/coverage data
to the affected collection; it neither swaps a root route nor edits a saved
form value. These three examples must appear together in the API review fixture
so naming makes the different commit and navigation behavior apparent.

## 5. Shared page, state and collection patterns

Retain existing root/route scaffolds, primary rails, adaptive master-detail and
page scroll owners. The page publishes content bounds and interaction bounds
separately. A feature body contributes slivers/content, not another full-page
scroll view with copied safe-area math. Forms/gallery/chart sub-scrolls are
explicitly scoped to their own axis/task.

Collection composition has distinct slots: optional lenses/counts; toolbar;
active-query summary; local notices/coverage; results; pagination. Use these
roles to coordinate spacing and separators without inflating Section or Field
with filter/provider options. A compact collection may omit every control.

State belongs to the smallest affected region: auth/organizer resolution can
replace the body while preserving root chrome; summary counts, results, detail,
pagination and individual mutations update independently. Unknown/truncated
counts remain unknown/partial, never fabricated zero or completion. Existing
rows remain during load-more failure. Empty with no data, no filter matches,
missing permissions, and failed loading have different meanings and actions.

Stable restoration uses account/organizer/view/entity scope. Query changes reset
the appropriate pagination; removal/filtering of a selected entity follows a
declared selection policy. Adaptive layout resolves once from available bounds,
and activation uses that same result for adjacent detail versus route push.
Large device width alone is not the pane's available width.

The following trees are responsibility diagrams. Supporting lines are not all
new public widgets. Each section names its current source and required behavior
so a future implementer can map these roles onto the extracted package.

## 6. Events: reference collection

Sources: `lib/hosts/events/presentation/host_events_screen.dart` and
`lib/hosts/events/presentation/widgets/host_events_list.dart`, especially
`HostEventsClubCard`, `HostEventsClubSection`, `HostEventsTimelinePage` and
`HostEventLifecycleRow`. Root source already uses canonical scaffold/rail/page
owners, stable organizer/view keys and separate lifecycle loading states.
Preserve its event-entry/draft/repeat capability and stable pagination boundary.

### Current problems and desired changes

- `HostEventsClubCard` loads data; it is not a card. Rename to
  `HostEventsWorkspaceAdapter` or absorb into the existing route adapter.
  `HostEventsClubSection` composes the entire workspace; rename to
  `HostEventsWorkspaceView`. `HostEventsTimelinePage` is an appropriate page
  adapter name. Prefer organizer vocabulary for new feature names without
  forcing a domain-model migration.
- The rail options and pages are independently enumerated. Use one stable
  view-definition source; derive the tab rail and page mapping from it.
- Month/day groups use generic plain sections and independent RecordRows.
  Replace with row sections and Field/RecordLayout. The title rule spans
  content width; sibling rules start under record text. Both tabs use the
  same recipe, even when the Past example originally exposed the defect.
- A `CatchSectionList` containing all rows inside one sliver adapter eagerly
  builds the collection. Use the shared lazy section contract, preserving
  group labels, record keys and bounded paging.
- Resolve header action layout from header constraints; preserve the current
  root title scrolling and pinned rail behavior. Do not add another toolbar
  or persistent strip solely to host New event.
- `now` controls lifecycle display; `sessionBoundary` controls a pagination
  session. Do not let each clock tick restart or duplicate the query.

### Proposed tree

```text
Host shell
└── HostEventsScreen / workspace adapter
    ├── organizer, timeline, drafts, stable session boundary, entry actions
    └── CatchRootScreenScaffold.withPrimaryRail
        ├── header: Events + New event command
        ├── Upcoming / Past rail from view definitions
        └── paged view presentation
            └── organizer + view scoped page viewport
                ├── initial loading / error / empty state
                └── lazy collection results
                    ├── Section.rows(header: day or month)
                    │   └── Field.navigate
                    │       └── RecordLayout(activity, title, facts)
                    └── pagination state/action
```

### Content and improvement contract

Keep the event title as subject, date/time and venue readable, attendance as a
separate fact and activity as leading identity. The feature formats facts and
localization; package layout does not import Event or choose activity policy.
Navigation supplies its affordance. Improve hierarchy through these roles,
not additional badges for every lifecycle fact. Preserve wrapping for long
titles/venues. A Past empty state does not need an unrelated creation prompt;
an Upcoming empty state can use the existing New event action. Pagination errors
belong after retained results rather than replacing the entire page.

Acceptance: three rows per group, at least two groups, both tabs, long localized
content, 2x text, real hover/gutter activation, correct rules, lazy construction,
refresh/paging identity and unchanged event-entry/navigation behavior.

## 7. Audience: collection controls and adaptive detail

Sources: `lib/hosts/presentation/host_audience_view.dart`,
`lib/routing/go_router.dart` (`hostAudienceScreenForUri`),
`lib/hosts/presentation/customers/host_customers_screen.dart`,
`host_customers_directory.dart`, `host_customer_row.dart`,
`host_saved_audiences_workspace.dart`, and
`lib/hosts/presentation/forms/host_forms_screen.dart`,
`host_form_responses_panel.dart`.

### Current problems and retained behavior

Four visible tabs are backed by two local pagers: People/Groups in
`HostCustomersScreen`, Forms/Responses in `HostFormsScreen`; crossing the pair
changes route screen, and the rail uses an offset of two for the latter pair.
Keep stable view identities (`audiences` is currently the Groups ID, not its
display label). Centralize view-to-route mapping, restoration, actions and
search configuration, while separating that mapping from optional paging.
Within-pair route synchronization currently differs; define one route contract.
Do not rename route IDs merely to match translated labels.

People's count lenses and sort/filter controls belong to collection controls,
not Section headers. Summary count requests and results can resolve separately.
Counts need exact/at-least/unavailable states. Search, filter summary, messaging
eligibility and sender-setup notices must keep their real domain conditions.

People's master/detail decision and record activation currently inspect whole
window width. Use the existing constraint-based adaptive owner and pass its
resolved mode to activation. Render selected detail in its own pane; preserve
the distinction between persistent selection and transient hover. Extract
shared customer detail content/actions from routed versus embedded wrappers
so each presentation owns exactly one top bar/scroll/inset policy.

Forms places a menu beside an Expanded RecordRow. Give that menu an explicit
Field secondary-action slot. Groups has a titled group section with count and
New group action, explanatory content and an Automations navigation section.
People, Forms and Responses may be headerless lists; do not force repeated
page/tab labels. Responses' All responses/Applications option group always
selects All responses while Applications pushes a child route. Use an explicit
application-review navigation action, retaining organizer/form scope.

### Proposed tree

```text
Host shell
└── Audience route / view coordinator
    ├── organizer, active view, per-view query, selected record
    └── Root scaffold
        ├── Audience header + active-view actions/search
        ├── People / Groups / Forms / Responses rail
        └── selected view presentation
            ├── People: adaptive master-detail
            │   ├── list pane viewport
            │   │   └── collection composition
            │   │       ├── All / Returning / New + independent counts
            │   │       ├── sort / filter controls
            │   │       ├── active-query summary / coverage / actions
            │   │       ├── results → headerless Section.rows
            │   │       │   └── Field.navigate → PersonLayout
            │   │       └── pagination
            │   └── detail pane → CustomerDetailContent
            ├── Groups: page viewport
            │   ├── membership/sort controls
            │   ├── results → titled Section.rows(count, New group)
            │   │   └── Field.navigate → RecordLayout
            │   ├── explanatory content
            │   └── settings Section.rows → Automations Field
            ├── Forms: page viewport / collection composition
            │   ├── lifecycle lenses + purpose/filter controls
            │   └── results → headerless Section.rows
            │       └── Field.navigate(RecordLayout, secondary menu)
            └── Responses: page viewport / collection composition
                ├── application-review navigation action
                ├── form/status filters
                └── results → headerless Section.rows
                    └── Field.navigate → PersonLayout
```

### Naming and improvement contract

Keep feature-specific identity, lifecycle and response formatting outside Catch
UI. `HostCustomerRow` becomes a Field-entry mapper when it has no separate state.
Keep rich last-seen/attendance text and relevant badges without promoting every
fact equally. Person identity payload must be separate from relationship/newness
and messaging status. A passive badge cannot double as an action slot.

Use collection-controls composition to own wrapping and separators now manually
placed by parents. Remove unused `shrinkWrap/condensed` props rather than imply
behavior they do not implement. Scope restoration to organizer/view, and define
what happens if filtering removes the selected person. Search expansion and
focus behavior should be explicit per-view capabilities, not unrelated ad hoc
header implementations.

Acceptance: all four views and route transitions; exact/partial/missing counts;
search/filter clear; async region isolation; form menu activation; no-results
versus empty; selected detail at narrow/wide bounds; long names/statuses; RTL;
headerless/titled rule geometry; keyboard focus and large-text controls.

## 8. Organizer: forms, dependent configuration and mixed content

Sources: `lib/hosts/presentation/host_operations/host_clubs_scaffold.dart`,
`host_club_edit_tab.dart`, `host_analytics.dart`, `host_organizer.dart`,
`host_club_spoke_screens.dart`, `host_club_team_screen.dart`, and
`lib/clubs/presentation/detail/club_detail_read_only_preview.dart` plus
`widgets/club_detail_body.dart`. Current root already uses Edit/Insights/Preview,
separate scroll controllers and the shared public sliver renderer for Preview.

### Edit

Identity and Contact already use typed `CatchFormRowList<UpdateClubPatch>`
descriptors and a shared `CatchAccordionController`. Preserve this direction;
close the arbitrary custom-row builder and keep coordinator state separate from
Field presentation. Permissions produce read-only Fields, not dead tappable
rows. Explicit field commits remain explicit; do not silently convert to blur
save or one giant whole-page Save action.

Media currently uses a field-row section around a thumbnail gallery. Change to
a content-section recipe with canonical header/count/Manage images action.
Media tiles retain media-specific interaction. Publication is one content/action
module: independent channel status rows can be read-only Fields; explanation,
primary command and error feedback occupy their own typed slots. Settings stays
a row section of navigation Fields to Event Defaults, Live Guide, Payments and
Host Team, with permission-sensitive availability.

The media draft/upload/retry/discard/snapshot state in Edit should eventually
move into an Organizer media-edit session/controller. It is separate from
field-level commits and publication commands. Preserve the existing manager's
explicit Save/Discard transaction and progress behavior. This controller move
is a follow-up improvement, not a prerequisite for the row geometry fix.

Root restoration combines organizer-specific keys with tab-only cached offsets.
Unify scope to organizer/view. Initial editor reveal targets the whole Edit
container; use a field-ID reveal contract with page-owned scrolling above the
keyboard/obstruction. Root navigation should not know a field's pixel position.

### Insights

**Agreed order:** selected-period performance → changes/decisions → supporting
detail; lifetime totals secondary. The current all-time/CRM-first arrangement
must not be preserved as a proposed target merely because it exists today.

Place date-range controls outside the report-success branch so results can fail
without losing query controls. Keep lifetime/CRM sources independent from period
report state. Use shared passive metric content with measured reflow, not a card
per number or forced two-column/one-line labels. Preserve metric currency,
period and partial/missing data semantics. Do not manufacture comparisons.

Use Field.disclosure for More metrics, not an arbitrary form control exemption.
Chart interaction remains chart-owned with keyboard/semantic access. Coaching
and recent-event entries use typed Field rows; remove `CatchFieldLanes.single`
inside the existing recent-event section. A business warning badge belongs to
content, not Field's action slot. Review metrics should share the same metric
anatomy rather than another bespoke grid/surface.

### Preview and settings routes

Keep the public organizer renderer shared between Consumer route and Host
Preview. The feature supplies saved/live data and read-only capabilities; the
host page supplies viewport/chrome. Test absent pointer, keyboard and semantic
actions, not only IgnorePointer. This is a saved-state preview unless an explicit
draft-preview feature is approved. Preview must not create a second vertical
scroll owner or duplicate route dock/safe-area clearance.

Settings are child feature workspaces with their own controllers, permissions,
route wrappers and shared content/form patterns. Team's professional-host
preview is not the Consumer dating profile. Payment onboarding, team authority,
policy persistence and Live Guide behavior remain app-owned.

### Proposed tree

```text
Host shell
└── Organizer route / feature controller
    ├── selected organizer, permissions, active view
    └── Root scaffold
        ├── organizer identity header + account actions
        ├── Edit / Insights / Preview rail
        └── view presentation
            ├── Edit: standard page / section stack
            │   ├── publication module
            │   │   ├── headerless row section → read-only channel Fields
            │   │   └── explanation + command + scoped feedback
            │   ├── Media content section → gallery/media tiles
            │   ├── form coordinator
            │   │   ├── Identity row section → Field + value/editor
            │   │   └── Contact row section → Field + value/editor
            │   └── Settings row section → navigation Fields
            ├── Insights: standard page
            │   ├── date-range query controls
            │   ├── performance/quality result sections
            │   ├── coaching/action Field section
            │   ├── trend + disclosure for supporting metrics
            │   ├── recent-event Field section + review metrics
            │   └── secondary all-time/CRM overview
            └── Preview: embedded public viewport
                └── shared public organizer sliver renderer

Media-manager route → media edit session
Settings routes → feature controllers + shared page/form composition
Dependent settings → controlling Field + attached dependent group
```

Acceptance: owner/non-owner editing, independent mutation errors, form Cancel/
Done and snapshot reconciliation, media transaction regression, deep-linked
field reveal, scoped restoration, Insights controls during failure, current-first
reading order, long metric labels, dependency stress case and public Preview
reuse without actionable editing or double chrome.

## 9. Today: operational overview, not a second Events inventory

Sources: `lib/hosts/today/README.md`,
`lib/hosts/today/presentation/host_today_screen.dart`, `host_today_body.dart`,
`host_today_overview.dart`, `host_today_feed_controller.dart`,
`host_today_state.dart`, `host_today_view_model.dart`. Preserve the existing
route/provider-free view boundary, bounded independent feed, typed handoffs,
live-event priority and stable session boundary distinct from the clock.

### Confirmed findings and changes

| Source anchor | Finding | Proposed correction |
|---|---|---|
| `host_today_overview.dart`, `HostTodayAttentionSection`/`HostTodayEventRow` | Generic divided section → adapter → single field lane → Field | Direct typed row entries, canonical header/rules and one geometry owner. |
| `_HostTodayWideLayout` | Hand-built two-lane Row with fixed-height decorative divider; no explicit pane interaction-plane reset | Reuse `CatchResponsiveSectionLayout` or extend its semantic primary/supporting layout; whole sections move together and each lane owns bounds. Keep one overview scroll owner. |
| Spotlight `taskCount`, state mapping | Count is a plain integer even when attention is unavailable; can imply zero work beside an attention error | Carry an app-derived count/availability/freshness summary and render unknown/partial honestly. |
| `HostTodayEventSpotlight` | Local contained flag, surface/dividers and fixed metric arrangement | Parent owns content-module presentation; shared passive metrics own content/reflow. Do not nest an already bordered metric strip blindly. |
| Header/time/venue rendering | Uses event-title or monoLabel/uppercase roles for screen title and ordinary context | Canonical screen title and readable record/time roles; review actual captures before claiming a font asset defect. |
| `_eventDayLabel` | Any evening event can be labelled Tonight without checking today's date | Localized feature formatter using injected clock, date and timezone. |
| `_todayEventHeroTitle` / relative labels | Strips English weekday/period prefixes from stored title and hardcodes temporal words | Preserve the event title unless a deliberate display-title rule is approved; localize temporal facts outside the renderer. |
| `HostTodayAttentionData.primaryActionLabel` | Declared action meaning is not consumed by the row | Provide Field activation semantics plus readable context/urgency; no duplicate button for the identical destination. |
| Feed/root | Event fetch and optional history can delay other useful data; retry exists without a declared user-refresh policy | Specify regional results and refresh/resume behavior with freshness, preserving independent valid data. No invented polling interval. |

### Target tree and ordering

```text
Host shell
└── HostTodayScreen / route adapter
    ├── auth, organizer, clock, feed, local-attendance work, typed actions
    └── Root scaffold.standard
        ├── canonical Today header / optional date context
        └── organizer-scoped page viewport
            ├── root loading/error/no-organizer state, or
            ├── operational section layout (stack or primary/supporting lanes)
            │   ├── relevant attention coverage/blocker notice
            │   ├── current/next event content module
            │   │   ├── lifecycle + event title + readable metadata
            │   │   ├── availability-aware metrics
            │   │   └── one primary lifecycle action
            │   ├── Needs you Section.rows
            │   │   └── Field.navigate → attention RecordLayout
            │   ├── bounded Later Section.rows
            │   │   └── Field.navigate → event RecordLayout
            │   └── View calendar / Dress Rehearsal handoff actions
            └── quiet workspace content when all authoritative inputs permit
                ├── truthful quiet summary
                ├── optional evidence-backed next-step module
                └── existing handoff actions
```

Today has no peer modes, so it does not need a decorative second tab rail.
In wide view, spotlight/horizon can occupy the primary lane and attention the
supporting lane. On compact, an immediate blocker/coverage notice may precede
the spotlight, with one destination to the ordered attention section. This is a
reading-order improvement to review; it must not duplicate tasks or replace the
backend's priority policy. A day without a featured event but with attention is
not an empty day.

Intentional `shortcutOnly`/`blockedMissingTruth` capability coverage is not
automatically a failed request or a required setup task. Scope quiet/all-clear
language to supported authoritative work; do not make a quiet state impossible
merely because a capability is intentionally outside the feed's coverage.

### Names, content and product boundaries

`HostTodayAttentionCard` is a navigation Field, not a card: replace it with an
entry mapper. `HostTodayEventDateBlock` renders an activity icon, not a date:
replace with activity leading data or a correctly named feature visual.
`HostTodayEventMetric` should use shared metric content. Replace `taskCount:int`
with a feature presentation summary containing count, availability and freshness;
do not expose backend coverage enums directly through generic UI components.
Remove unused display/fill props once consumer census proves they have no role.

Treat quiet Today as a frequent established-organizer experience, not a failed
onboarding screen. Keep Calendar and Rehearsal as real handoffs. An optional
recommended next step must be grounded in authoritative capabilities and
evidence; unknown setup state is not incomplete or complete. Reconcile the
separate **Plan Host Today onboarding** work before adding a milestone model.
The audited main does not contain that personalization; do not present it as
implemented or copy its historical state without review. Public organizer page,
payout setup, CRM import and event creation remain distinct destinations.

Acceptance: current/next/no-event-with-attention/quiet states; missing and partial
attention never become zero-task/all-clear claims; stable seven-day/three-later-
event bounds; local conflict/retry handoffs; future evening versus Tonight;
midnight/locale/clock changes; scoped refresh; long venue/title; 2x text; lane
transition geometry; unknown recommendation evidence; no regression of the
Today/Events authority split.

Recommendation-specific checks apply only if the optional personalization
follow-up is adopted. They are not a requirement to add it in this migration.

## 10. Messaging: workspace, directory, transcript and composer

Sources: `lib/hosts/presentation/inbox/host_inbox_screen.dart`,
`host_inbox_view_model.dart`, `host_whatsapp_thread_sheet.dart`,
`host_sends_workspace.dart`, `host_manual_send_queue.dart`,
`host_campaign_composer.dart`, `host_broadcast_composer_sheet.dart`,
`lib/chats/presentation/inbox/widgets/chat_conversations_list.dart`,
`lib/chats/presentation/chat_screen.dart`, its message/context/composer widgets,
and `lib/routing/go_router.dart` (`hostInboxScreenForUri`).

Keep the shared root scaffold, `HostMessagingWorkspaceRail`/`CatchTabRail`, the
constraint-driven `CatchAdaptiveMasterDetailLayout`, per-thread draft behavior
and existing channel/controller seams. The root product destination is currently
Messaging, containing Inbox and Sends. Changing its label to Chat is a separate
product decision, not implied by this architectural work.

### Scope and collection controls

`HostInboxScopeSelector` already uses `CatchMenuAnchor` and choice-role items.
The defect is not that no shared menu exists. Its **trigger** is a local
Material/InkWell, fixed-height row, uppercase bold mono text, activity-colored
and restricted to one line. The trigger synthesizes weekday + event-format
label; options use the actual `event.title`. A renamed event can therefore look
like a different event after selection. Same-day copy also assumes Tonight.

Use a canonical scope picker Field with a persistent label, the actual selected
event title in value typography, date/time as separate metadata and a canonical
disclosure affordance. Package-owned selection internals handle trigger input,
focus, expanded state, option selection and return focus. Keep General scope
and existing event ordering; do not invent All conversations. Reconcile existing
adaptive-selection internals with pane-local constraints before reusing them.
Small sets may use anchored choices; larger/ambiguous sets need search and
date disambiguation. Phone width alone does not require a bottom sheet.

Booked/Prospective is a collection filter, not another navigation rail. Rename
the wrapper `HostInboxAudienceRail` to `HostInboxSegmentFilters` and use the
same semantic filter/count recipe as Audience. Current counts describe Catch
inquiry threads; roster-backed announcement recipients are a separate count,
and appended WhatsApp entries are not in those inquiry totals. **The new target
counts distinct people after authoritative identity resolution**, within the
chosen scope/segment. Do not relabel today's thread counts as people or use
roster-recipient totals. Unavailable identity/classification or incomplete source
coverage must remain explicit; missing participation is not automatically
Prospective. Filter counts exclude search unless the control explicitly promises
search-result counts, and share one documented coverage contract with results.

### Conversation list and result state

**Agreed revision (2026-09-08): organize Messaging by person, not channel.** One
known person has one row and one combined conversation view across linked Catch
and WhatsApp threads. Remove Catch/WhatsApp section headings and duplicate person
rows. This supersedes the earlier plan to share only browse geometry while
leaving channel-separated lists/details. Keep the existing event/General scope;
this decision does not itself broaden visibility or infer event attribution.

Three current constructions must converge:

| Current construction | Replacement |
|---|---|
| Catch conversations: PersonRow with its own divider/press behavior, external selected `ColoredBox` | Person conversation projection → Section entries → Field.navigate with selected person → ConversationLayout |
| WhatsApp conversations: tappable `CatchSurface.card` with separate hierarchy | Contributes messages/endpoints to the same person projection; an additional person row only when identity is distinct or unresolved |
| Sends history: read Field → single FieldLanes → external RowPressSurface → divided FieldLanes → divided Section | Navigable Field entries directly in a row Section; no read-only Field made clickable externally |

Conversation content has person identity/name, latest visible message preview
(including no-message state), timestamp and known activity/unread state. Channel
is message/delivery context, not the list's grouping or primary subject.
Do not use `lastMessage != null` to choose the layout. Do not hardcode a running
icon for arbitrary context, as `CatchPersonChatLayout` currently does. A typed
context visual is supplied by the feature. WhatsApp's available timestamp should
be shown; unread counts/read receipts must not be invented.

Current search appears based on Catch count only, so WhatsApp-only results can
lose search. Catch matches names while WhatsApp also matches the last message,
despite name-search copy. Define one query meaning and expose search when either
channel has content or a query is active. A feature-owned coordinator joins the
independently paged sources into one person result set, ordered by latest known
message activity with stable identity tie-breaking. Catch UI only renders its
typed presentation data. No name-based matching in a widget or layout.

WhatsApp loading/error currently becomes an empty list and its `nextCursor` is
unused. Add local channel loading/retry/coverage/paging without replacing usable
Catch results. Events, Catch threads and participations currently form a blocking
group; failure of participation classification should not remove scope controls
or credible conversations. Never guess Booked/Prospective membership before its
authoritative classification resolves. Empty, no matches and unavailable data
need distinct copy and actions.

### Person identity, ordering and transport contract

The audited source already distinguishes the necessary ownership:
`ChatThreadPreview` in `lib/chats/presentation/inbox/chats_list_view_model.dart`
exposes `otherUid/matchId`; `HostWhatsappThreadSummary` in
`lib/hosts/data/host_crm_repository.dart` exposes `contactId/threadId`.
`HostAudienceContactDetail` exposes linkage/confidence state, and
`HostCommunicationRecipientPlan` exposes contact-scoped available/recommended
routes. These are useful existing boundaries, **not proof that an exact combined
Inbox projection already exists**. Trace the authoritative identity mapping and
extend its projection/contracts as needed; do not invent the join client-side.

- A canonical organizer-scoped person key owns list/detail selection. Under it
  retain typed source thread/endpoint IDs. Use the existing CRM/account identity
  authority and its resolved merges/links, never matching display names or a
  widget-normalized phone number. Shared numbers, ambiguous candidates and
  unlinked accounts remain unresolved. Unifying the view does not authorize
  silently merging CRM records, creating accounts or changing contact ownership.
- Preserve source authorization and event/General eligibility before combining.
  Render channel/event context where known; do not assign every message to every
  event on a thread's summary. Resolve ambiguous message-scope coverage explicitly
  in the feature projection. A merge must not expose another organizer's history.
- One lazy result entry per resolved person; preview comes from the newest
  eligible message across linked sources. Distinct message keys include channel,
  source thread and source message ID. Equal text is not a duplicate-message
  key. Timeline order uses authoritative timestamps and stable tie-breaks;
  pending messages keep stable client/request identity when acknowledged.
- Joining two first pages does not prove complete global ordering/counts. Reuse
  or add a server-owned person index, or implement a bounded merge with explicit
  per-source cursors/watermarks and partial coverage. Late pages update an existing
  person rather than append a duplicate; source failure retains known history
  with a scoped notice. Do not claim the preview is globally latest while a
  relevant source is unavailable.
- Unread/activity state has known, partial and unavailable forms. Aggregate only
  supported read models; for example a known Catch count plus unknown WhatsApp
  state may render `2+` with accessible explanation, never an exact combined 2.
  No badge cannot imply everything is read. Mark only source-supported visible
  messages read; selecting a person does not fabricate a WhatsApp read receipt.
- One transcript interleaves the authorized history, with channel labels on
  message metadata or at changes and accessible provenance on every message.
  Keep source delivery/read status local to that message. Existing send-history
  reports remain in Sends; merging the Inbox does not turn campaigns into
  ordinary chat messages without a corresponding message record.
- The composer states **Reply via Catch/WhatsApp**. Use existing route-availability
  policy for the initial recommendation and show the chosen route before send.
  Retain the chosen route while a draft/pending request exists; do not silently
  switch after a new inbound message, a service-window expiry or send failure.
  Route changes are explicit; one send targets exactly one endpoint. No automatic
  fallback, fan-out, broader consent or WhatsApp attachment support.
- Draft/pending-send identity includes organizer, person, scope and reply route;
  changing route must not accidentally send another route's pending draft. Keep
  channel-specific drafts or explicitly support a validated transfer. Preserve
  uncertain-retry idempotency and re-evaluate eligibility at dispatch. Contact
  re-link/merge/split invalidates stale projections and safely reconciles selected
  identity/drafts without silently changing a pending recipient.

This is now a required app/data projection slice as well as a presentation
change. Generic Catch UI does not import CRM identities, reconcile sources,
choose delivery routes or implement channel permissions.

### State, detail and specialized boundaries

The screen synchronizes segment changes, but `_routeQuery` does not serialize
the segment and the route resolver does not parse it. Use one typed state for
workspace/scope/segment/query/selection, with an explicit serialized subset and
one parser/encoder. Preserve existing deep-link values. Query/draft restoration
need not expose private message text in a URL.

Selected-conversation identity is organizer + canonical person, with explicit
scope. Transport request/draft identity additionally includes channel + endpoint.
Resolve old thread deep links through that source-to-person mapping and retain
their message anchor/context. Reconcile selection and cached drafts on organizer
changes; reject late results for the old scope.
This is a state-correctness requirement, not a demonstrated backend permission
bypass. Resolve split rendering and click behavior from the same local width,
as Inbox already does. Each pane owns its viewport, interaction edges and
obstruction; selected-row state alone must not mark a conversation read.

`ChatScreen.embedded` currently changes back-button behavior while still building
a route scaffold. Separate routed/pane wrappers from shared conversation content
so a detail pane does not pretend to be a route. Preserve its controller,
read-marker, identity/context, permissions and action seams.

Transcript and composer are explicit exceptions to ordinary row composition:

- Transcript owns date/message grouping, bubble alignment/width and history
  scroll. Existing Catch message and timestamp type roles are appropriate;
  do not label all chat typography defective. Replace the context header's
  raw tiny font/weight override with a canonical context/status role.
- Composer owns dock/perimeter, multiline input and send/attachment controls.
  Native text input retains caret, selection and IME. Move full input-lane focus
  targeting into its sanctioned control API instead of an extra GestureDetector
  around a bare Field. Preserve separate text/attachment pending state and clear
  only the unchanged draft that was successfully sent.
- WhatsApp transcript should use local sheet/pane width rather than whole-window
  percentages. Preserve its distinct service-window eligibility and text reply
  operation; no new attachments or Catch read/delivery semantics.

The combined person detail is shared by compact routed and wide pane wrappers.
Channel-specific sheets may remain for specialized actions, but selecting the
same person must not open a different primary history based on their last
channel. A foundational geometry slice can precede this integration; the complete
Messaging migration now requires the person-based list and combined detail.

### Sends and dependency-heavy composers

Replace competing composing/choosing booleans and nullable reports with one
feature flow state: history, intent choice, composing an intent, or a typed
report. Keep history as the landing state, with New send/settings, actionable
manual work and paged history. Conversation intent navigates to Inbox; it is
not a dispatch command. Reports retain each channel's actual status vocabulary.

Campaign template → variables/linked event → invite destination is a useful
adopter of the shared dependency model after the base Field/Section migration.
Use typed form sections, saved-audience/template/event pickers and an editable
schedule Field with clear/validation behavior. Recipient-definition editing
belongs in Audience. Event-provider failure is not an empty choice set.
Broadcast intent/template explanations remain attached to their alternatives.

Preserve existing approval, consent, sender/template availability, quotas,
scheduling and idempotency policy in feature code. Manual WhatsApp launch is
not proof of sending. Consolidating controller state must retain the existing
opened-handoff/mark-sent distinction and reset/fence manual-work paging on
organizer change. No tests in this migration send live messages.

### Proposed tree

```text
Host shell
└── HostMessagingScreen / route coordinator
    ├── workspace, scope, segment, query, selected person
    ├── person-conversation coordinator: identity links + source coverage
    └── workspace presentation
        ├── Inbox: adaptive master-detail
        │   ├── master viewport
        │   │   ├── Messaging header + search
        │   │   ├── Inbox / Sends rail
        │   │   └── collection composition
        │   │       ├── headerless Section.rows → scope picker Field
        │   │       │   └── selected-value layout
        │   │       ├── Booked / Prospective filters when applicable
        │   │       ├── channel/classification notices and coverage
        │   │       ├── one lazy Section.rows, grouped by person
        │   │       │   └── Field.navigate(isSelected)
        │   │       │       └── ConversationLayout
        │   │       │           ├── person identity + name
        │   │       │           ├── latest message / typing / no-message state
        │   │       │           └── timestamp, known/partial activity, context
        │   │       └── merged-result pagination / source coverage
        │   └── detail viewport / empty selection
        │       ├── identity header + available actions
        │       ├── optional event/channel context
        │       ├── combined transcript → date groups → message bubbles
        │       │   └── source channel / timestamp / known delivery state
        │       └── composer dock → explicit reply route + native input
        │           └── route availability / scoped draft and pending send
        └── Sends: bounded operational page
            ├── Messaging header + Inbox / Sends rail
            └── flow state
                ├── history
                │   ├── New send + settings actions
                │   ├── manual-work Section.rows → Fields
                │   ├── history Section.rows → Field → RecordLayout
                │   └── pagination
                ├── intent choice → explained choice/navigation Fields
                ├── composer → form coordinator
                │   ├── peer Fields + attached dependency groups
                │   └── preview/approval/dispatch as feature policy permits
                └── report → channel status + permitted actions

Compact route → routed wrapper → same person conversation content
Source thread deep link → identity resolver → person + source message context
```

Names: `HostInboxScreen` → `HostMessagingScreen` because it also owns Sends;
use `HostInboxView`/`HostSendsView` for their presentations. Map the current
`HostMessagingWorkspace.campaigns` value to `sends` in app vocabulary with an
explicit legacy route-value adapter. Keep `/host/inbox` compatibility unless a
separate route migration is intended. `HostInboxScopePicker` is a feature adapter,
not another generic popup implementation. Conversation layout activity should
have authored precedence, not independent `isFresh/showFreshBackground/
showFreshDot` switches that can disagree.

Acceptance: one row/combined history per resolved person across channels; real event identity in picker
and options; General/long/removed/duplicate-title scopes; segment route round-trip;
WhatsApp-only search; partial/error paging; local-width selection/draft retention;
organizer revision fences; transcript grouping and keyboard obstruction; blocked/
closed/service-window reply states; failure retains draft; successful matching
send clears it; channel capabilities unchanged; Sends flow states exclusive;
dependent composer validation, applicability and retention tested. Add the
person-identity/ordering/route cases in §12; a shared row style alone no longer
satisfies this acceptance.

## 11. Enforcement specification

The prevention strategy has four independent parts: **remove invalid public
configurations, reject ownership bypasses, prove real rendering/behavior, and
make the correct semantic recipe easy to discover**. Prose and screenshots alone
cannot prevent recurrence; lints alone cannot prove runtime paint or good product
hierarchy. Extraction is a location change until these contracts are enforced.

### API/compiler and static checks

Use `packages/catch_ui_lints` and existing composition/component checks. Names
below are proposed diagnostics, not currently registered promises. Prefer closed
types and compiler failures where possible, resolved-symbol lints for legal Dart
that violates ownership, and rendered tests for geometry. Keep existing exact
specialized owners for controls/media/transcripts, not blanket directory waivers.

| Rule / extension | Reject or diagnose | Positive control / proof |
|---|---|---|
| `catch_row_interaction_is_field_owned` | Legacy press surface, raw recognizer or selection fill wrapping an ordinary row; external press around read Field | Field.navigate with selected state, sanctioned standalone button or native input; resolved symbol rule |
| `catch_field_layout_is_passive` | Recognizer, focus target, action semantics, row state paint or sibling divider in a passive layout/helper | Avatar/text/badge layout, Field secondary-action slot; closed descriptors plus renderer dependency checks |
| Extend `catch_field_requires_section_context` | Rows in generic content/plain sections, fake lane wrappers, untyped entry builders or invalid helper branches | Typed entries/lazy builders and transparent feature factories; scope assertion for runtime ancestry |
| Extend geometry/divider ownership rules | Consumer plane/radius/outset knobs, row-owned bottom border, manually interleaved sibling rules | Page/pane bounds and Section rule renderer; valid avatar ring or real pane divider |
| Strengthen row-header contract | Titled row collection without canonical content-width rule or separately rebuilt header chrome | Header data on row Section, explicit headerless row collection, non-row editorial heading |
| Public package boundary | Raw renderer exports/re-exports, external `src/` imports, new unclassified interactive list family | Resolved public API plus independent consumer compile fixtures; exact internal owners |
| Semantic control/typography contract | Hand-built scope-picker trigger, primary tabs used as filters, function label using restricted kicker treatment in a typed role | Registered tab/filter/picker/command recipes and role-appropriate text; context-aware diagnostic, not a global mono-text ban |
| Root/pane composition checks | Feature-owned shell inset math, width resolution duplicated between list and activation, unintended nested root scroll/scaffold | Existing root/adaptive owner and separate routed/pane content wrappers |

The last two require both source contracts and production tests. A general lint
cannot infer whether arbitrary words are an event name, whether a raw Row is a
filter, or whether business data is authoritative. Bind high-confidence rules
to resolved public roles, and surface unclassified interaction candidates for
explicit review. Do not claim a clean regex scan proves semantic conformance.

### Analyzer and discovery requirements

- Resolve declaration identity through prefixes, exports, aliases, redirecting
  factories and constructor tear-offs. Names resembling approved widgets are
  not approval. Analyze supported helper/conditional/builder paths separately;
  one valid branch cannot hide another invalid return.
- Unknown/dynamic values at a protected entry boundary require a typed adapter.
  Avoid pretending a local AST ancestor proves a runtime widget ancestor. Sealed
  types, package scope assertions and production tests cover different facts.
- Discover all installable apps, shared app code, Catch UI, examples and
  Widgetbook from the package/source graph. Fail if expected roots or intended
  fixtures resolve to zero files. Renderer ownership checks still apply inside
  the package even where consumer rules do not.
- Internal access is limited to exact renderer/control owners and their `part`
  units. Do not exempt all of `/packages/`, `/core/widgets/` or `/presentation/`.
- Negative probes assert diagnostic **code, location and count**, with matching
  valid controls. Include external-package relocation and removing a lint
  registration/root/owner mapping as failure cases.
- Keep expected-invalid fixtures outside shipping/example code. Reuse existing
  component enforcement declarations, not a new conformance registry. Temporary
  migration waivers name exact symbol/path, reason, owner and expiry; no new debt
  and no permanent waiver for an ordinary record disguised as a card.

Required negative fixture forms: direct/prefixed/re-exported/aliased calls,
helper return, mixed valid-invalid conditional, builder, constructor tear-off,
external consumer and a custom class named like an approved primitive. Include
the original padded Person press surface, Record in a plain section, row-owned
bottom border, hidden hover helper, Add bypass, external selected fill and direct
internal import. Positive controls include passive nested Flutter Rows, avatar
borders, Field-owned secondary controls, native input and a pane boundary.

### Coverage and exception discipline

The migration census must inspect raw gesture/list/tile construction, private
adapters, returned helpers and sliver builders, not just `*Row` names. Cover menu/
choice/Add/index/host/roster/detail/history/settings families and all five screens.
Classify each live composition as an ordinary Field entry, a sanctioned control,
or an expressive/specialized component with its own contract. Skeletons use the
same geometry but have no live activation/focus. Passive fragments inside one
owning row need no additional Field. Keep this classification in existing
component ownership metadata where needed; do not create a tracked evidence log.

## 12. Verification specification and acceptance

These are implementation requirements, **not tests run by this documentation
pass**. Package behavior must work in an independent Flutter consumer with no
Catch app, Riverpod, Firebase, router, ARB class or app schema dependency. App
tests then prove the actual five screens use those contracts.

### Shared contract matrix

| Test family | Setup | Assert |
|---|---|---|
| Original regression | Production Organizer Identity, Audience People, Events Upcoming/Past; 3 rows/group, 2 groups, inset content | Same full-bleed feedback reach, content-width title rule, actual text-lane sibling start; primary activation once |
| Interaction | Plain/person/record/conversation/Add/choice/toggle/input; hover enter/exit, down/up/cancel, focus, selected, open, saving, disabled | Real mouse hover paints without pressing; deterministic precedence; focus remains visible; no sticky state after rebuild/unmount |
| Extent/input | Phone gutter, capped readable width, split pane, sheet/menu, nested section | Paint, primary hit and semantics reach the granted extent; gutter taps work; no adjacent-pane hit; text stays inset |
| Rounded/contained | Explicit inset group; single/first/middle/last/dependent entries | Rounded exterior pixels, one clip, internal bands contained; no square outer corner or double frame |
| Rules | Empty/single/multiple rows; no leading/icon/avatar/variable leading, mixed typed layouts/factories, lazy entries, LTR/RTL | `max(N-1, 0)` rule positions, visible at rest; actual text lane and trailing edge; titled rule spans content; no last-row rule or guessed inset |
| Transitions | One/two adjacent active rows during hover/press/open/focus/selection and reduced motion/theme changes | Sibling opacity follows §3's policy, restores only as both inactive, retains layout space; header/perimeter stable; intermediate frames have no double stroke/flash |
| Secondary/native input | Menu/message button, toggle, clear/submit, reorder handle, text editing | Only intended action fires; correct focus order; no duplicate native input semantics or intercepted text selection |
| Semantics | Navigation/read-only/disabled/selected/toggle/disclosure/unread states | Correct role/value/action, exactly one primary action where applicable; keyboard and semantic activation tested independently |
| Responsive content | 320/390 logical widths, constrained wide lane, two panes; scales 1/1.5/2; long localized values/status | Usable content/actions, measured reflow, stable text lanes, no shrink-to-fit or critical unintended truncation |
| List lifecycle | Insert/remove/reorder/filter/page under stable identities with stationary/moving pointer | Focus/selection follow identity or declared removal policy; hover recomputed under pointer; pressed gesture never retargets another record; separators update; lazy rows stay lazy |
| Dependency/form | Parent/prerequisite graph, unknown ID/cycle, >2 inline levels, continuation, inactive/collapsed/reopened state | Validation/applicability and retained draft/submitted patch distinct; ancestor errors reveal; continuation implemented; cancel/commit/focus preserved |

Measure painted inner rule/text anchors and corner pixels, not only wrapper
`getRect` or `overlayRect == rowRect`. Test edge input separately from outpaint.
One-physical-pixel raster rounding tolerance cannot conceal a logical gutter
mismatch. Use light/dark and directional variants where relevant, touch target
policies and actual mouse events. Prefer representative golden combinations
with deterministic behavior assertions over an unbounded Cartesian golden suite.

### Screen and state tests

| Screen | Required app-level cases beyond shared geometry |
|---|---|
| Events | Both tabs and stable view mapping; creation/repeat/drafts unchanged; empty vs failed; session boundary survives clock ticks; refresh/paging retains identity |
| Audience | All 4 views, route/back restoration, query reset, partial/unavailable counts, independent notices, form secondary menu, Applications navigation, local-width detail selection and removal policy |
| Organizer | Permissions/read-only, explicit commit/cancel and snapshot conflict handling, media Save/Discard, field-ID reveal above keyboard, organizer/view restoration, period-query controls during failure, agreed Insights order, saved public Preview without actions/double chrome |
| Today | Current/next/attention-only/quiet, unknown attention count, event-independent attention failure, local attendance retry/conflict, bounded horizon, future-evening date copy, midnight/timezone/locale, freshness/refresh; evidence-backed quiet recommendations only if that optional follow-up is adopted |
| Messaging | Exact selected event identity; General/no events/removed scope/20+ options; segment encode/parse/back; person grouping/search/counts across channels; partial failure/paging; organizer/person/source revision fences; draft/selection across resize; no read until detail active; reply-route capability/service-window cases; mutually exclusive Sends flow |

Use fake clocks, repositories and deterministic permissions/projections. For
sending, verify stable request identity on uncertain retry, failure retains
draft, success clears only the matching draft, and text/attachment pending
remain independent. Keep existing permission/idempotency suites authoritative;
no live dispatch, privacy-policy change or new capability is part of a UI test.

Person-conversation integration fixtures must prove:

1. One person with Catch and WhatsApp source threads produces one row and an
   ordered combined timeline; two people with the same name remain distinct.
   Shared-number, ambiguous/unlinked-account and conflicting-link cases do not
   merge by guesswork. The same identity in two organizers cannot cross scopes.
2. Booked/Prospective counts use distinct resolved people and authoritative
   participation; unknown is not Prospective. New pages or linkage updates do
   not append duplicate rows. Preview/count/order claims reflect source coverage.
3. Equal timestamps and repeated message bodies retain distinct source IDs;
   duplicate delivery/page retries deduplicate only by authoritative identity.
   Late messages update activity ordering while preserving selected person and
   scroll anchoring. Partial history/source failure remains visible locally.
4. Known Catch unread plus unsupported WhatsApp unread remains partial; no exact
   total, all-read claim or synthetic source receipt. Source read markers update
   only when eligible history is actually active/visible.
5. Reply route is visible and dispatches once to its selected endpoint. Switching
   route preserves separate drafts, limits attachments to that route and leaves
   uncertain sends bound to their original idempotency key/recipient. Window
   expiry/failure/new inbound activity cannot silently switch channel or fan out.
6. Old thread/message deep links resolve to the correct person/context. Identity
   merge/split/re-link and organizer switches fence late pages, selection and
   pending drafts; permission loss cannot retain unauthorized history.

These extend app/data integration suites, not only Catch UI widget tests. Derive
data-contract and backend checks if the implementation changes those projections.

### Mutation proof

Every mutation below must have a named failing compiler/lint/widget/state or
paint assertion. Valid controls must remain green. These are focused mutations,
not a requirement to adopt a new mutation-testing service.

1. Restore a parent-sized square overlay inside an inset page, or paint full
   bleed while narrowing its hit region to content.
2. Remove hover-enter handling but retain press feedback.
3. Replace the Events row section with plain, omit the header rule, or set a
   sibling rule to zero/icon inset/physical-left in RTL.
4. Add a layout recognizer, external selection fill, or return Add/Sends to a
   legacy press wrapper.
5. Remove the group clip or restore separately rounded internal row frames.
6. Drop a consumer root/lint registration, or re-export a private geometry API.
7. Reintroduce the scope trigger's ad hoc interaction/text role or use a
   synthetic format label in place of the selected actual event title.
8. Omit segment serialization; turn unavailable attention into zero; hide a
   channel failure as empty; accept an old organizer's late page/result.
9. Validate only visible form rows, submit retained inactive values, or allow an
   inline chain past the declared depth without an implemented continuation.
10. Group people by channel or name, count source threads as people, present a
    partial unread total as exact, or silently reroute/fan out a pending reply.

### Existing extension points and visual acceptance

Extend/reconcile these current suites and owners; verify their paths and actual
coverage again on the implementation base:

- `packages/catch_ui_lints/lib/src/catch_ui_rules.dart` and its probes;
  `tool/check_catch_ui_lints.sh`; existing component enforcement/ownership checks.
- `tool/design/check_section_headers.mjs`, `check_section_dividers.mjs`,
  `check_root_screen_composition_contracts.mjs` and the field inventory tools.
- `test/core/widgets/catch_section_test.dart`,
  `catch_section_interaction_tests.dart`, `catch_section_field_groups_test.dart`,
  `catch_responsive_section_page_test.dart`, `catch_field/lanes_test.dart` and
  field mode/input/focus/save/constructor tests; Person/Record/Index suites.
- `test/hosts/host_events_layout_test.dart`,
  `host_operations_customers_tests.dart`, `host_inbox_screen_test.dart`,
  `host_inbox_view_model_test.dart`; existing Organizer and Today suites.
- `test/chats/chat_conversations_list_test.dart`, `chat_input_bar_test.dart`,
  `chat_screen_test.dart`, `chat_event_context_header_test.dart`; channel tests.

Package-owned tests may still be app-located after extraction; move/share them
according to real dependencies rather than blindly relocating every test file.
Update outdated assertions, such as row-local People feedback and uppercase
GENERAL INQUIRIES, to the new contract. Preserve meaningful existing behavior.

Review Widgetbook **and production compositions** at compact/large-text and
constrained wide widths. Capture the original three hover states side-by-side,
Messaging scope/open/selected states, Today normal/quiet/partial data, Organizer
Insights and the Event Policy dependency stress case. Review visual hierarchy,
wrapping and motion against the agreed rules; passing structure alone is not
visual acceptance. Never update goldens merely to bless a failed invariant.

## 13. Implementation slices, remaining decisions and completion

The actionable priority is to fix the shared contract and reference rows first,
then apply the same grammar to controls and larger compositions. Do not make a
five-screen controller rewrite a prerequisite for fixing the original defect.

| Slice | Deliverable | Exit condition |
|---|---|---|
| A. Reconcile current source | Fresh main/extraction state, consumer census, existing owners, API fixture for the five use cases | No assumed package names/exports; exact legacy/exception classification; no concurrent work overwritten |
| B. Contract and failing proof | Typed entries/layouts, capability/prop decisions, scope/default geometry, exported API and negative fixtures | Invalid states rejected at the narrowest reliable layer; tests reproduce original defects |
| C. Field/Section kernel | One interaction owner including Add/hover; passive layouts; text-lane rules; full-bleed paint and input; contained clip; private renderers | Package/compiler/lint/behavior/paint fixtures pass; existing editor/accordion/commit behavior preserved |
| D. Three reference screens | Events + all Audience modes + Organizer Field/content roles | Original three screenshots corrected by common implementation; routing/forms/state cases and captures pass |
| E. Today and Messaging roots | Today row/metric/coverage composition; scope picker/filters; authoritative person-conversation projection and merged timeline; explicit reply route; Sends history; scoped state fixes | Two additional root trees proven, one row per resolved person, identity/count/order/coverage and channel capabilities verified |
| F. Dependent and mixed-content adoption | Event Policy stress case, agreed Insights order, composer dependency groups, selected controller/body extractions | Accepted hierarchy/visuals and validation/retention/flow tests; no auto-modal or unapproved policy change |
| G. Close remaining consumers | Remaining menu/index/host/roster/history/settings adapters, examples/Widgetbook, API and waiver deletion | No live bypasses or legacy public shells; generated contracts current; package and apps enforce the same rules |

Slices may be split into reviewable changes while sharing the same contract.
Every consumer migrated uses the final ownership model; compatibility shims may
forward configuration temporarily but cannot retain old interaction logic.
Structural naming changes accompany the slice changing that responsibility.
Cosmetic domain/route renames, Today personalization and media-controller
extraction remain separately bounded follow-ups unless needed by an agreed
acceptance case. Person-based cross-channel Inbox/detail is now agreed scope;
implement its identity/read-projection contract before claiming the combined
experience is complete. Geometry may land first as a clearly partial slice.

### Decisions still requiring targeted review

- **Final API spelling:** compile representative call sites for record/person/
  conversation, secondary menu, explicit editor, filters and dependency group.
  Prefer the names in §4; do not proliferate aliases. Decide whether the form
  coordinator separation warrants `CatchFormSection` before committing a rename.
- **Visual recipes:** review control wrapping, attached dependency tint/toggle
  alignment and long values, plus Today reading order. Full-bleed defaults,
  content-width header rules and no inset square perimeter are already decided.
- **Audience navigation:** preserve the existing within-pair swipe behavior
  initially. A unified cross-four-tab swipe interaction is a separate choice;
  centralized view/route state does not require it.
- **Draft reconciliation:** preserve current commit/retention behavior first.
  Specify each feature's external-update conflict policy before changing it;
  package geometry cannot decide which domain value wins.
- **Messaging search/counts:** retain name search initially. Person grouping,
  combined history and distinct-person counts are agreed; §10 defines their
  identity/coverage contract. Verify the actual identity authority and required
  projection extensions before implementation. Broader message-body search
  remains a separate choice; channel-separated grouping is no longer an option.
- **Today recommendations:** reconcile the separate onboarding work and use
  authoritative evidence. Geometry and truthful error/count states can proceed
  without introducing a recommendation engine.

Bring back only a concrete unresolved choice with examples and its consequence.
These review points do not require asking again about already agreed boundaries.

### Durable rule placement and definition of done

Update `docs/design_language.md` for deterministic precedence/geometry (including
the older implicit split-pane rounding rule), `docs/app_architecture.md` for
ownership, `docs/widget_catalog.md` and existing component contracts for public
APIs/recipes, and existing feature responsibility sources for feature behavior.
Record the person-conversation projection and identity/source boundaries in the
existing data-contract owners if those contracts change; it is not package UI
state. Keep identity resolution with People/CRM and delivery policy with Messaging.
Generate their derived outputs through current tools. Keep a small production
example per semantic use case, linked from those owners. Remove conflicting
older examples and deprecated public constructors; don't leave two supported
ways to build the same interactive row.

Derive required checks on each changed base using
`node tool/harness/verify_local.mjs --base origin/main --list`, then run the
selected gates and focused suites for that slice. Do not freeze this document's
extension-point list into a new CI authority or run parallel Flutter analyzers/
test processes. Dependency-impact selection must include package consumers and
fail when required discovery disappears.

Completion means the ordinary-row census is migrated/classified, forbidden APIs
and temporary waivers removed, public consumer compile and lint probes pass,
shared geometry/interaction/state/mutation tests pass, all five production trees
are adopted, and required rendered review is complete. Preserve exact source
diff/commit and report source checks, CI, merge and device verification separately.
If later slices remain, report them as remaining work; a corrected People row
alone is not completion of this system change.

After transferring implemented requirements into the existing owners and checks,
retire this temporary plan. Git preserves its design history; no replacement
audit ledger or tracked test-run receipt is needed.

## 14. Ready-to-send implementation task

> Implement the Catch UI composition and Host-screen handoff in
> `docs/plans/catch_row_section_conformance_handoff.md` (version 2.1.0,
> 2026-09-08). Read the complete specification and the current owning documents.
> Retrieve the spec from `codex/catch-ui-composition-handoff-20260908` if it has
> not reached main; it is the replacement for the earlier narrower handoff.
> The spec's source baseline is `6030865f9c95a7513fc71d7d72e79782e506fd57`, where
> Phase 3 extraction was merged; begin from freshly fetched main in a guarded
> worktree and reconcile extraction follow-ups and concurrent feature changes.
>
> Deliver Section → Field → passive layout for ordinary rows, full-bleed default
> feedback with working gutter hit targets, explicit rounded containment,
> canonical content-width header rules and text-lane sibling dividers. Close
> public geometry/interaction escape hatches, including person/record/conversation
> row shells. Preserve specialized controls, media, transcripts and composers.
> Use the five screen trees and API sketches as the implementation contract,
> resolving recommended naming through representative compile fixtures.
>
> Implement the lint/compiler, package, app-state, paint/semantics and focused
> mutation checks specified here. Prove the original Organizer/Audience/Events
> regression, then adopt Today and Messaging and the stated dependency/mixed-
> content slices. Reconcile the dependency foundation at checkpoint
> `c5434f42dde36dfc4ba972fe717541f22cdeae22`; do not transplant its old branch
> wholesale or treat unfinished visuals/continuations as completed work.
>
> Preserve domain/permission/save/send behavior and route compatibility. Provide
> one Inbox row and combined authorized history per resolved person across Catch
> and WhatsApp, using authoritative identity links, honest counts/coverage and an
> explicit reply route. Preserve source messages/permissions and channel-scoped
> idempotency; no name matching, silent transport fallback or contact mutation.
> Keep optional follow-ups separate and raise only concrete unresolved decisions.
> Work in the reviewable slices in §13, extend existing authorities/checks, derive
> required gates from the current planner, and preserve each coherent result in
> Git. Provide production captures and distinguish automated verification from
> visual acceptance. Report remaining scope honestly; do not equate package
> extraction, a passing lint or a source commit with a completed device fix.
