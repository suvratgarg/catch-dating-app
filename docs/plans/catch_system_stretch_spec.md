# Catch System Stretch Spec — Field 10/10 Goals + Adjacent Canonical Surfaces (for Codex)

Status: implementation complete; both owner gates approved and closed · 2026-07-19
Scope: `lib/core/widgets/` (field family, top bar family, async/error/loading family, section layout), `lib/core/forms/`, `lib/core/schema_contracts/` + `contracts/` (S1 codegen), `lib/core/theme/` (motion usage only — no new token values without owner sign-off), `design/components/` (S5), `test/core/`, `widgetbook/`, `tool/`, docs.
Supersedes: §14 of [`catch_field_section_system_spec.md`](catch_field_section_system_spec.md) ("base spec") — that section was a sketch; THIS document is the implementation contract for S1–S6. The base spec's §14 remains as rationale.
Companions: [`host_club_edit_and_live_guide_spec.md`](host_club_edit_and_live_guide_spec.md) ("edit spec"), [`host_club_insights_spec.md`](host_club_insights_spec.md) ("insights spec").

Owner has authorized S1–S6 for implementation (2026-07-17), plus the
adjacent-surface phases in §9–§10. Items marked `⚠ OWNER` retain their
specific gates (mostly taste sign-offs), everything else is ratified.
The owner approved both remaining gates on 2026-07-19: S2 production motion
and the §9.4 semantic content-width follow-up.

---

## 0. Verified current state (2026-07-17, working tree)

The base spec's Phases A–E are DONE and verified:

- Phase B split landed: `catch_field.dart` 1,068 lines + parts
  (`_state` 719, `_edit` 806, `_row_modes` 752, `_control` 677,
  `_lanes` 843, `_scopes` 72). All under the 1,500 gate. (Main file is 68
  lines over its <1,000 target — accepted, do not churn it further.)
- `expanding`/`actions` facades deleted repo-wide.
- New slots landed: `toggle.helperText`/`badgeLabel`/`badgeTone`;
  `choices.helperText`/`itemAccent`.
- Phase A test matrix landed: `test/core/widgets/catch_field/`
  (`row_modes/toggle/input/control/lanes/save_status_test.dart`).
- Phase D landed further than the prototype gate: `lib/core/forms/
  catch_form_descriptors.dart` (924 lines — descriptors, `CatchFormRowList`,
  per-row editors, save-state) with the **consumer profile tab migrated**.
  Reviewed: accordion ownership handoff in `didUpdateWidget` is correct;
  API matches the ratified sketch.
- Phase E doctrine landed at `docs/design_language.md` §7.3.

Open items inherited from the base specs (§10 of this doc schedules them):

| # | Item | Why it is now unblocked |
|---|---|---|
| O1 | Host club edit tab (and its spoke screens) still hand-wire inline editors; only `user_profile` consumes `lib/core/forms/` | Base spec §9.3 ordering — the forms layer now exists and is proven on consumer |
| O2 | `HostInlineOptionEditor` still hand-rolls a chip `Wrap` inside `CatchField.control(` (`host_inline_editors.dart:333`) | Base spec §7.3 gated this on the edit spec's Phase 3 immediate-commit save model, which has landed |
| O3 | A NEW `CatchField.control(` call site appeared at `host_analytics.dart:382` (insights rebuild) — unaudited against the base spec §7.3 composite-only rule | Audit and either justify (composite) or migrate to `choices` |

## 1. Goals and non-goals

Goals:

1. S1 — form constraints derived from the schema contracts; UI-vs-contract
   drift becomes machine-checked (highest value).
2. S2 — one motion language for the edit loop (owner-gated choreography).
3. S3 — per-mode private configs so illegal `CatchField` states don't
   compile.
4. S4 — accessibility + dynamic-type invariants in the Phase A matrix.
5. S5/S6 — cross-stack interaction contract + agent-legible registry,
   implemented and enforced after owner activation (§7/§8).
6. §9 — the same canonicalization standard applied to the adjacent
   super-configurable surfaces found in the 2026-07-17 survey: the top bar
   family, the async/error/loading family, and terminal padding.
7. §10 — close the O1–O3 leftovers.

Non-goals:

- No visual redesign of any surface; §9 phases are API/consistency work
  with pixel output unchanged except where a straggler adopts the
  canonical widget.
- No new motion token VALUES without owner sign-off (S2 composes existing
  `CatchMotion` durations/curves; additions are proposed in the prototype,
  not invented inline).
- No changes to `packages/catch_ui_lints` (plugin edits crash local
  analyze — repo memory). New checks ship as `.mjs`/Dart tools in the
  manifest.
- S5 and S6 are governance-only additions: they do not alter Flutter visuals
  or behavior, and React shares interaction semantics rather than widget code.
- No second row/top-bar/error system anywhere. Consolidation only.

## 2. Cross-cutting rules

Base spec §4 and edit spec §3 apply verbatim (branch discipline + context
packs, copy pipeline + ARB key convention, PATH export, per-phase §12 gates,
catalog updated in the same PR as any API change, passes.jsonl stamps).
Additionally:

1. Every phase in this doc is independently landable; do not chain PRs
   across phases except where §11 sequences them.
2. Hardcoded English defaults in core widgets are treated as defects
   wherever touched (the survey found `'Search'` ×4 and `'Try again'` ×2 —
   §9 removes them); new core-widget parameters must never carry hardcoded
   user-visible English defaults.
3. When a phase deletes public API, verify zero usages in `lib/`,
   `widgetbook/`, AND `test/` first (the base spec's census pattern), and
   record the census in the PR description.

## 3. Phase S1 — Contract-derived form constraints (highest value)

### 3.1 Problem, restated with current evidence

Field constraints live twice: descriptor/call sites (`maxLength: 280` on
club description, 300 on host goal) and the JSON schemas behind the
generated patch DTOs (`contracts/` → `lib/core/schema_contracts/generated/`).
Nothing connects them; they have already drifted once (280 vs 300 was found
in review). S1 makes the schema the single source and the UI a consumer.

### 3.2 Design

**S1a — constraints registry codegen.**

1. Locate the schema-contracts generator (start at `contracts/README` and
   `tool/tools_manifest.json`; do NOT hand-write generated output). Extend
   it to emit a new artifact
   `lib/core/schema_contracts/generated/field_constraints.g.dart`:

   ```dart
   /// GENERATED — one record per leaf field of the patch/document schemas
   /// that carries UI-relevant constraints.
   class CatchContractFieldConstraints {
     const CatchContractFieldConstraints({
       required this.path,        // e.g. 'updateClubPatch.description'
       this.maxLength,
       this.minLength,
       this.required = false,
       this.pattern,              // regex source, if schema declares one
       this.enumValues,           // List<String>? for enum fields
       this.minimum, this.maximum // nums for numeric fields
     });
   }

   abstract final class CatchContractConstraints {
     static const updateClubPatchDescription = CatchContractFieldConstraints(...);
     // ... one const per field, plus:
     static const all = <String, CatchContractFieldConstraints>{ ... };
   }
   ```

2. Source of truth: the same schema files the DTO generator reads. Only
   emit fields that have at least one constraint; absence of a field in the
   registry is not an error.

**S1b — descriptors consume the registry.**

1. `CatchFormTextRow` (and the other typed rows in
   `lib/core/forms/catch_form_descriptors.dart`) gain an optional
   `CatchContractFieldConstraints? contract`. When present it derives:
   `maxLength`/`LengthLimitingTextInputFormatter`, required-ness (empty
   validator), and pattern validation — while explicit per-row overrides
   remain allowed but become ASSERT-checked against the contract in debug
   (`assert(maxLength == null || contract == null || maxLength <=
   contract.maxLength)`).
2. Migrate the two live form surfaces (consumer profile tab; host club
   edit surfaces as part of §10 O1) to pass `contract:` for every field
   that has a registry entry. Delete the now-redundant literal limits.

**S1c — the drift gate.**

1. A Dart test (`test/core/forms/contract_alignment_test.dart`) walks the
   descriptor lists produced by the app's form-state factories (consumer +
   host) and fails when a row that maps to a contract path either lacks
   `contract:` or contradicts it. The form-state factories therefore expose
   their rows for testing (they already do on consumer).
2. Manifest entry + wire into the flutter-ci lane alongside the existing
   contract check (`./tool/check_data_contract.sh` untouched).

### 3.3 Acceptance

- Regenerating contracts regenerates the registry deterministically
  (golden diff in CI is clean when schemas are unchanged).
- The 280-vs-300 class of drift reproduced in a seeded fixture fails the
  S1c test (anti-vacuity: prove the gate fires, per repo gold standard).
- No behavior change visible to users beyond corrected limits, which must
  be listed in the PR description if any are found.

## 4. Phase S2 — One motion language for the edit loop ⚠ OWNER (taste gate)

### 4.1 Scope

Choreograph, from existing `CatchMotion` tokens (`catch_tokens.dart:1499`),
exactly four moments — no others:

| Moment | Today | Target |
|---|---|---|
| Accordion / inline editor expand & collapse | instant or default | one shared duration+curve pair; content fades/slides ≤ 8 px; scroll-into-view on expand keeps using the existing reveal alignment |
| Disclosure drawer (`CatchFieldDisclosureDrawer`) | as built | same pair as accordion — one language, not two |
| `CatchFieldStatus` idle→saving→saved | swap | saving spinner cross-fades in; saved tick scales in with `easeOutBack`, holds (existing timer), fades out |
| Chip selection (`CatchChip.selectable` inside choices) | as built | selection fill/outline animates with the short duration token; no layout shift |

### 4.2 Process (the gate)

1. Build `widgetbook/lib/primitives/field_motion_use_cases.dart` with
   knobs for each moment and a side-by-side "current vs proposed" story.
   Propose token ADDITIONS (if any duration/curve is missing) in the story
   description — do not add them to `catch_tokens.dart` yet.
2. ⚠ OWNER reviews the Widgetbook story and signs off (motion is a
   locked-identity concern per `docs/design_language.md`).
3. Only then wire into the production widgets, honoring
   `MediaQuery.disableAnimations` (precedent: the map-reveal reduced-motion
   test) — reduced motion degrades every moment to a plain swap.
4. Extend `save_status_test.dart` + `control_test.dart` with
   reduced-motion assertions (animations skipped) and pump-through tests
   (no pending timers leak — the saved-tick timer already exists; reuse its
   discipline).

Owner sign-off: approved 2026-07-19 from the Widgetbook review story. The
production implementation uses `CatchMotion.base`, `CatchMotion.fast`,
`CatchMotion.standardCurve`, and `CatchMotion.easeOutBackCurve`; no motion
tokens were added.

### 4.3 Acceptance

Owner sign-off recorded in the PR; reduced-motion path tested; zero new
raw duration/curve literals outside `CatchMotion` (the existing lint
regime's spirit — cite the token in code).

## 5. Phase S3 — Illegal CatchField states don't compile

Completes the base spec's Phase B. Mechanical; public API unchanged.

1. Introduce private per-mode config types in the `catch_field.dart`
   library (sealed, const):

   ```dart
   sealed class _CatchFieldConfig { const _CatchFieldConfig(); }
   final class _RowConfig extends _CatchFieldConfig { ... }      // read/content/nav/action/add
   final class _ToggleConfig extends _CatchFieldConfig { ... }
   final class _EditConfig extends _CatchFieldConfig { ... }     // input/inputActions
   final class _SelectConfig extends _CatchFieldConfig { ... }
   final class _ControlConfig extends _CatchFieldConfig { ... }  // control/choices/stepper/expanding-like
   ```

   Each holds ONLY the fields its build path reads (derive the field→mode
   ownership from the consolidated validity matrix the base spec Phase B
   put on the private constructor — it is the migration checklist).
2. Public named constructors construct their config subtype; the private
   constructor becomes `const CatchField._fromConfig(this._config, {shared
   row params...})` where "shared" is the small set every mode reads
   (title, body, icon, tone, divider, key). All public constructors MUST
   remain `const` — if any config field blocks const-ness, stop and
   restructure that field rather than dropping const.
3. `_CatchFieldState` dispatches on an exhaustive `switch (_config)` —
   delete the mode enum branch-and-null-check style as each path migrates.
   `CatchFieldMode` stays public only if anything external reads it
   (census first; likely test-only — then move it into tests or derive
   from config).
4. Land as 3–4 stacked PRs (one config family at a time), each keeping the
   whole Phase A matrix green unchanged. Same "diff confined to
   core/widgets + tests" gate as Phase B.
5. Acceptance: the 84-parameter constructor is gone; no single constructor
   path exceeds ~30 parameters; a deliberately illegal combination (e.g.
   toggle + controller) is a compile error, demonstrated in a
   `// intentionally does not compile` doc snippet in the PR.

### 5.1 Implementation outcome (2026-07-18)

S3 is complete without dropping public const construction or exact public
widget identity. `CatchField.read/content/nav/action/add`, `toggle`,
`input/inputActions`, and `control` are const redirecting factories into sealed
private row, toggle, edit, and control implementations; the generic select
facade constructs the fifth sealed implementation directly. The private
implementations store only their mode's fields, and `_CatchFieldState` switches
exhaustively over that sealed hierarchy. The former record typedefs,
`Object _configData`, runtime materializer, and unknown-config fallback are
deleted.

The private implementations report the public `CatchField` runtime type. This
preserves `Widget.canUpdate`, `find.byType(CatchField)`, and the same state object
when a keyed field changes mode; the row-mode matrix pins all three. The
existing intentionally-noncompiling toggle-plus-controller snippet above
remains the illegal-combination proof. The long public input facade is retained
unchanged as required by the public-API constraint; the former 84-parameter
all-mode private path is gone, and no private constructor mixes multiple mode
families.

## 6. Phase S4 — Accessibility + dynamic type as tested invariants

One bounded audit-plus-test pass over the field family; encode results in
the Phase A matrix so regressions fail CI. Invariants to verify and pin:

1. **Semantics**: every interactive lane exposes a role + label (toggle
   rows report toggled state; nav rows report button; choice chips report
   selected; the trailing save lane is `liveRegion` or announced — see 2).
2. **Announcements**: `CatchFieldStatus` transitions announce
   "Saving" / "Saved" via `SemanticsService.announce` (l10n'd strings, new
   ARB keys), exactly once per transition. Error lane text is announced on
   appearance.
3. **Targets**: interactive lanes hold ≥ 44 px hit targets (CountPill test
   precedent — reuse its assertion helper; extract it to a shared test
   util if copy-pasted today).
4. **Dynamic type**: at `textScaleFactor` 1.3 and 2.0, per mode: no
   overflow errors; the value lane wraps below the title instead of
   truncating meaning (verify existing clamp behavior; where a row
   truncates user data at 2.0, switch that lane to wrap). Add a scale-
   parameterized test group per mode file.
5. **RTL smoke**: one `Directionality(rtl)` test per mode file asserting
   lanes mirror (chevrons, leading icons) — smoke only; full RTL audit is
   out of scope.

Deliverables: the audit findings table (what already passed — expected:
much of it, given the focus-semantics suite), the fixes, and the new test
groups. No API changes expected; if one is needed, it must go through the
catalog per doctrine.

## 7. Phase S5 — Cross-stack interaction contract (IMPLEMENTED 2026-07-19)

Trigger (unchanged from base §14): the next substantial admin-forms work
order. The owner explicitly activated this gate on 2026-07-19.

1. Extend `design/components/catch.components.json` with an
   `interactionContracts` block for two concepts:

   ```json
   "interactionContracts": {
     "field_row": {
       "modes": ["read", "content", "nav", "action", "toggle", "input", "control", "choices", "optionCards", "stepper", "inputActions", "add", "select"],
       "slots": ["title", "body", "leading", "value", "placeholder", "control", "support", "badge", "action", "prefix", "suffix", "feedback", "status", "error", "actions"],
       "saveStates": ["idle", "saving", "saved"],
       "rules": ["one expanded editor per group", "row owns its divider", "empty editable rows use canonical add copy"]
     },
     "field_section": {
       "variants": ["divided", "fieldRows", "containedFieldRows", "contained", "plain"],
       "slots": ["title", "subtitle", "trailing", "count", "footer", "children", "child"]
     }
   }
   ```

   Exact vocabulary comes from the then-current Flutter API (regenerate,
   don't transcribe this snippet blindly).
2. Admin React forms map onto the same contract with native
   implementations (implementation sharing stays ruled out). Extend the
   existing component-governance checker
   (`node tool/run.mjs check web:react-component-governance`) to require
   admin form components to declare which contract mode they implement.
3. Acceptance: one admin form family (pick the work order's surface)
   passes the extended checker; the lexicon registry validates against its
   schema; no Flutter changes.

Implementation receipt: the exact current Flutter API yields 13 field modes
(including `optionCards`), 15 semantic slots, three save states, and five
section variants. Organizer Publishing is the native React adoption; its
`TextField`, `TextareaField`, `SelectField`, and `CheckboxField` registry
entries declare `input`, `select`, and `toggle` mappings. The component
governance checker validates declarations and live family usage. No Flutter
source changed.

## 8. Phase S6 — Agent-legible field registry (IMPLEMENTED 2026-07-19)

Trigger (unchanged): field-system corrections become a recurring review
theme in agent work orders. The owner explicitly activated this gate on
2026-07-19.

1. `tool/design/generate_field_inventory.mjs`: parse
   `lib/core/widgets/catch_field.dart` (constructor names + parameters via
   the analyzer or a resilient regex over the split files) and emit
   `docs/audit_registry/field_facade_inventory.json`: facade → mode →
   slots → "use when" line (the "use when" lines are authored once in a
   sidecar map inside the tool, reviewed by owner).
2. A `--check` mode fails when code and inventory drift (audit-registry
   pattern). Manifest entry; wire into the design check lane.
3. Fold the §7.3 doctrine of `docs/design_language.md` into the JSON as
   `forbiddenSurfaces` so agents consume rules as data.
4. Acceptance: deleting a facade or adding a slot without regenerating
   fails CI; the seeded-probe rule applies (prove the check fires).

Implementation receipt: `tool/design/generate_field_inventory.mjs` parses the
live public factory and static-facade declarations plus CatchSection variants,
validates the cross-stack vocabulary, and emits the committed inventory. Its
test suite seeds a deleted facade, an added semantic slot, and a missing
owner-reviewed use-when line. The manifest registers the check in the design
lane.

## 9. Adjacent canonical surfaces (2026-07-17 survey findings — ACTIVE work)

The same standard the field system just met, applied to the other
super-configurable core surfaces. Findings verified in code; census
commands in each subsection's PR description per §2.3.

### 9.1 Top bar family (`catch_top_bar.dart`, 1,336 lines)

Findings:

- TWO parallel top bars: `CatchScreenTopBar` (factory, PreferredSize,
  11 call sites) and `CatchTopBar` (stateful, 46 params, 17+1 call sites),
  EACH carrying a duplicated ~12-parameter search-lane bolt-on
  (`searchValue/searchEnabled/searchExpanded/onSearch.../search*Color`).
- Hardcoded English defaults: `searchPlaceholder = 'Search'`,
  `searchTooltip = 'Search'` — in BOTH classes (×4 total).
- `CatchSliverTopBar` has **zero** usages anywhere (dead limb).
- `CatchScreenTopBar` requires a `BuildContext` in its factory to
  precompute height (PreferredSizeWidget constraint).
- Overlapping action affordances on `CatchTopBar`: `actions` list AND
  `actionIcon/actionVariant/actionLabel/actionText/onAction` shortcuts.

Work items, in order:

1. **T1 — delete `CatchSliverTopBar`** (census first per §2.3). Keep
   `CatchSliverHeader`/`CatchCollapsedSliverTitle` (used).
2. **T2 — extract the search lane config**: one immutable
   `CatchTopBarSearch` object (value, enabled, expanded,
   onExpandedChanged, onChanged, onSubmitted, onFocusChanged, placeholder,
   tooltip, semanticLabel, autofocus, textInputAction, collapsedExtent,
   colors...) consumed by BOTH bars as a single `search:` parameter.
   Placeholder/tooltip become REQUIRED on the config (no English
   defaults); migrate all call sites passing l10n values, add the ARB keys
   where callers relied on the defaults. Net: −24 parameters across the
   two constructors, one search contract.
3. **T3 — action affordance audit**: census the
   `actionIcon/actionLabel/...` shortcut params on `CatchTopBar`; if call
   sites ≤ 3, fold them into `actions:` and delete the shortcuts; if
   widely used, keep and document the division in the catalog. (Decision
   by census, recorded in the PR.)
4. **T4 — characterize and document the two-bar split** in
   `docs/widget_catalog.md`: when `CatchScreenTopBar` (static screens) vs
   `CatchTopBar` (stateful/search/identity). Full merge is NOT ratified —
   propose it only if T2/T3 reveal >80 % param overlap, as a follow-up
   with its own census. The `BuildContext`-in-factory stays (constraint
   documented in a doc comment; do not invent a workaround).
5. **T5 — split the file** on the base spec's Phase B pattern if it still
   exceeds 1,000 lines after T1–T3 (parts: screen bar, stateful bar,
   search lane, sliver pieces, actions).

### 9.2 Async / error / loading family

Findings:

- `CatchAsyncValueView` carries BOTH context-less (`data`, `loading`,
  `error`) and context-ful (`builder`, `loadingBuilder`, `errorBuilder`)
  callbacks for every state — migration residue; 19 call-site files.
- `CatchErrorState` (modes fullScreen/inline/compact, `.fromError`) has a
  hardcoded `retryLabel = 'Try again'` default in two constructors.
- Skeleton system is healthy (259 usages) — leave it alone.

Work items:

1. **E1 — collapse the dual callbacks**: keep ONLY the context-ful
   `builder`/`loadingBuilder`/`errorBuilder`; migrate the context-less
   call sites mechanically (wrap in `(context, v) => ...`); delete the old
   parameters and the runtime `assert(data != null || builder != null)`
   in favor of `required this.builder`. One PR, ~19 files, zero behavior
   change.
2. **E2 — l10n the retry label**: `retryLabel` loses its English default;
   `.fromError` resolves it from l10n internally (it already receives
   context at build; if the label is needed pre-build, thread l10n the way
   `CatchField.defaultEmptyValueText` does). Census callers passing
   custom labels; keep the parameter.
3. **E3 — catalog doctrine line**: skeleton for page/section loads,
   `CatchLoadingIndicator` for inline waits, `CatchErrorState.fromError`
   + `AppErrorContext` for failures, `CatchAsyncValueView` as the default
   three-state composer. One paragraph; it is current practice — write it
   down so it stays true.

### 9.3 Terminal padding (platform/nav-bar bottom clearance)

Findings: the system is well designed (`AppShellActiveTab` publishes
`none/anchored/floating` placement + overlay inset;
`CatchScrollTerminalPadding`/`CatchSliverTerminalPadding` consume it;
17 adopter files). Two stragglers hand-roll safe-area bottom padding:
`lib/payments/presentation/payment_history_screen.dart:340` and
`lib/hosts/presentation/event_management/host_create_event_route_loading_screen.dart:105`.
(`viewInsets.bottom` keyboard math elsewhere is legitimate — not in scope.)

Work items:

1. **P1** — migrate both stragglers to the canonical widgets (verify each
   screen's shell context: inside a shell tab → default `includeSafeArea`;
   route-pushed full screen → same default works per
   `scrollTerminalClearanceOf` fallback).
2. **P2** — guard: extend an existing design `.mjs` check (or add
   `tool/design/check_terminal_padding.mjs`) flagging
   `paddingOf(context).bottom` / `viewPadding.bottom` in `lib/` outside
   `lib/core/` (allowlist: `viewInsets` keyboard uses). Seeded fixture
   proves it fires; manifest entry. Skip the check if the census shows the
   pattern recurring is implausible — do not ship a vacuous gate
   (owner's success-criteria principle); note the decision either way.
3. **P3** — document the `AppShellBottomBarPlacement` contract (the doc
   comment on `scrollTerminalClearanceOf` is good — lift it into
   `docs/app_architecture.md` where shell chrome is described).

### 9.4 Bounded survey of the remaining configurable surfaces

One time-boxed audit PASS (no fixes in the same PR) over:
`CatchBottomSheetScaffold`, `CatchSurface`, `CatchButton`, `CatchChip`,
`CatchAdaptiveDialog`/`catch_adaptive_picker`, `CatchOptionGroup`,
`CatchTabbedScreenScaffold`/`CatchTabbedPageScrollView` (width-constraint
default from the edit spec §4.1 — consider promoting the ConstrainedBox
into the scaffold now that three call sites do it), and `CatchBottomDock`.
For each: line count, param count, dead named constructors (census),
hardcoded English defaults, duplicated config clusters. Output: a findings
table appended to THIS doc as §9.4.1 with per-item dispositions
(fix-now / doctrine / leave), owner-reviewed before any fixes are
scheduled. The survey grep set from this doc's PR description is the
starting point.

### 9.4.1 Configurable-surface findings (2026-07-18)

The owner reviewed the bounded survey on 2026-07-19 and approved its sole
`fix-now` item. The semantic content-width follow-up is now implemented;
parameter counts below remain the original survey snapshot. Usage counts
include `lib/`, tests, and Widgetbook unless called out.

| Surface | Lines | Public parameter count | Dead named constructors | English defaults | Duplicated configuration / finding | Disposition |
|---|---:|---|---|---|---|---|
| `CatchBottomSheetScaffold` | 242 | 11 | None; 24 uses | None (`keyboardSafe` only reads keyboard insets) | `title`/`subtitle`/`glyph`/`badge`/`trailing` form one intentional header-composition cluster; callers need only one sheet shell. | doctrine — keep the single shell and document header roles; do not add named variants. |
| `CatchSurface` | 264 | base 18; `card` 10; `tinted` 7; `message` 9 | None; base 223, card 23, tinted 5, message 12 uses | None | The base color/elevation/border cluster overlaps the three semantic named constructors, but the named constructors already remove illegal combinations at the common call sites. | doctrine — prefer semantic named constructors; retain the base escape hatch for compositional surfaces. |
| `CatchButton` | 337 | 13 | No named constructors; 194 uses | None | `variant` plus four color overrides is the only overlap cluster. `accentColor` has a bounded primary-action role; arbitrary colors remain needed by reviewed warning/brand actions. | doctrine — variants first, overrides only for registry-backed accents or reviewed semantic colors. |
| `CatchChip` | 380 | `tag` 6; `selectable` 7; `activity` 6; `removable` 7 | None; tag 7, selectable 20, activity 11, removable 4 uses | None; removable semantics use `MaterialLocalizations` | The private 13-field storage object is shared, while each public constructor exposes a disjoint interaction contract. No public duplicated cluster survives. | leave — the typed constructors are the desired state. |
| Adaptive dialog + picker | 414 combined | adaptive dialog 5; confirm helper 7; confirm/form widgets 3 each; date picker 5; time picker 3 | None; APIs are function-based | None; confirm/cancel/date/time/done copy resolves through l10n | Cupertino/Material branching repeats by necessity, while dialog card geometry and Cupertino picker-sheet chrome are already shared internally. | leave — platform branching is explicit and localized. |
| `CatchOptionGroup` | 307 | 10 | No named constructors; 18 uses | None | Variant, scrolling, trailing content, divider, and controller-driven `selectionPosition` describe orthogonal layout/animation concerns; no repeated caller bundle justified another config type. | leave — keep the current parent-owned selection contract. |
| `CatchTabbedScreenScaffold` + `CatchTabbedPageScrollView` | 238 | scaffold 12; page 7 | None; one production scaffold and three production page uses | None | All three live page uses repeat the centered `ConstrainedBox(maxWidth: CatchLayout.maxContentWidth)` pattern around primary box content, while the page primitive already owns overlap and terminal padding. | complete (2026-07-19) — `constrainToContentWidth` centers box-content slivers around the canonical 600 px lane only when the viewport has surplus width; narrow layouts remain direct and Preview remains full-bleed/sliver-native. |
| `CatchBottomDock` | 37 | 3 | No named constructors; 16 uses | None | Padding and safe-area ownership are the entire contract; no duplicated mode cluster. | leave — small, semantic, and correctly bounded. |

## 10. Base-spec leftovers (O1–O3) — scheduled

1. **O1 — host surfaces onto the forms layer**: migrate the host club
   edit tab + its spoke screens (edit spec §7.1) from `HostInline*`
   editors to `CatchFormRowList` descriptors, per the base spec §9.3
   ordering (edit spec Phase 3 has landed, so this is a migration, not a
   rebuild). `HostInline*` classes are deleted as their last consumers
   migrate. S1b's `contract:` parameter is adopted in the same pass —
   sequence AFTER S1a lands to avoid double-touching every row.
2. **O2 — `HostInlineOptionEditor` chips → `CatchField.choices`** with
   `itemAccent` + `helperText` (unblocked; part of O1's migration —
   choice rows become `CatchFormSingleChoiceRow` and the hand-rolled Wrap
   dies with the editor class).
3. **O3 — audit `host_analytics.dart:382`** `control:` usage against the
   composite-only rule; migrate to `choices`/`stepper` if it is a plain
   selector, else record the justification in the catalog census.

## 11. Sequencing

```
S1a → S1b → S1c
         ↘ O1+O2 (after S1a; adopts contract: in the same migration) → O3 anytime
S2 (independent; owner gate at the Widgetbook story)
S3 (independent; stacked PRs)
S4 (after S3 lands OR before it starts — not interleaved with it)
9.1 T1..T5, 9.2 E1..E3, 9.3 P1..P3 — independent of everything above and
of each other; land opportunistically between the S-phases.
9.4 survey any time; its fixes are a future doc section.
S5/S6 — dormant until triggers fire.
```

## 12. Verification gates (per phase)

```sh
export PATH="$HOME/development/flutter/bin:$PATH"
flutter analyze
flutter test test/core test/user_profile test/hosts
flutter gen-l10n                                   # after ARB edits (T2/E2/S4)
node tool/run.mjs check design:widgetbook-contract-refs
node tool/run.mjs check design:widgetbook-coverage
node tool/run.mjs check --manifest-only            # after any tool additions (S1c/S6/P2)
./tool/check_data_contract.sh                      # S1 phases
node tool/agent/check_agent_readiness.mjs
```

Plus per-phase specifics: S1a golden-regen diff; S2 owner sign-off note;
S3 "diff confined to core/widgets + tests"; seeded anti-vacuity fixtures
for every new check (S1c, P2, S6); `node tool/test_inventory.mjs` after
test additions; catalog + passes.jsonl stamps throughout.

## 13. Confirmed healthy — do NOT "fix"

- The base spec's §13 list, in full — everything it protects is still
  protected here.
- `AppShellActiveTab` + terminal padding design (the survey's verdict:
  well designed; §9.3 is adoption + documentation, not redesign).
- The skeleton system (259 usages, consistent) — no changes.
- `CatchTopBar`'s stateful search-lane animation behavior — T2 moves its
  config, not its behavior.
- `adaptive_platform.dart` (`prefersCupertinoControls`) — tiny and right.
- `lib/core/forms/catch_form_descriptors.dart` accordion ownership and
  save-state handling — reviewed 2026-07-17, correct; S1b extends it
  without restructuring.
- The two-top-bar split until T4's census says otherwise — do not merge
  speculatively.

## 14. Implementation completion audit (2026-07-19)

This matrix maps every active or trigger-gated phase to current authoritative
evidence. Both decisions reserved for the owner were approved on 2026-07-19
and are included in the completed implementation.

| Scope | Current evidence | State |
|---|---|---|
| S1a — generated constraints | `tool/contracts/generate_schema_contracts.mjs` emits `field_constraints.g.dart`; `--check` reports all generated schema outputs current. | complete |
| S1b — descriptor adoption | Consumer profile and Host Club edit descriptor factories bind their constrained rows to `CatchContractConstraints`; the former 280/300 literals and Host inline editors are absent. | complete |
| S1c — drift gate | `contract_alignment_test.dart` covers both factories and contains the seeded contradictory-limit probe; Flutter CI and `tools_manifest.json` run it. | complete |
| S2 — motion language | The owner-approved `field_motion_use_cases.dart` story covers exactly four moments and reduced motion. Production fields now share `CatchMotion.base`/`standardCurve` for editor, drawer, chevron, and scroll reveal; drawer content fades/slides at most 8 px; status cross-fades/scales with cancellable dismissal; `CatchChip.selectable` retains its short token and layout; no token was added. | complete |
| S3 — exact field modes | Const public factories redirect to sealed row/toggle/edit/select/control implementations; the old object payload/materializer and `CatchFieldMode` are absent; state dispatch is exhaustive and the identity test pins `Widget.canUpdate`, `find.byType`, and state continuity. The public input facade remains long because public API compatibility and const construction are both explicit constraints; no all-mode private constructor remains. | complete |
| S4 — accessibility | The catalog audit table records roles, announcements, targets, dynamic type, and RTL findings. Row, input, select, toggle, and control tests pin localized one-shot announcements, live errors, 44-point targets, 1.3×/2.0× rendering, and RTL lane mirroring. | complete |
| S5 / S6 | No substantial admin-forms work order or recurring field-correction trigger fired. Their artifacts remain deliberately absent. | dormant by trigger |
| T1–T5 — top bars | `CatchSliverTopBar` is absent; both bars consume required-copy `CatchTopBarSearch`; action shortcuts are absent; the split and `BuildContext` constraint are documented; the main file is 895 lines. | complete |
| E1–E3 — async/error/loading | Async composers expose only context-aware builders; retry copy resolves through l10n; the catalog records skeleton/loading/error doctrine and the corrected current API. | complete |
| P1–P3 — terminal padding | Both named stragglers use `CatchScrollTerminalPadding`; the seeded manifest-backed scanner passes; `docs/app_architecture.md` owns the shell placement contract. | complete |
| §9.4 survey | The bounded findings table is present and owner-reviewed. `CatchTabbedPageScrollView.constrainToContentWidth` replaces the repeated Edit/Insights wrappers, remains direct at narrow widths, and leaves the sliver-native Preview page unconstrained. | complete |
| O1 / O2 | Host Club edit uses `CatchFormRowList` and typed choice descriptors; the hand-rolled Host inline editor classes are absent. | complete |
| O3 | Host Insights keeps `CatchField.control` only for the documented composite time-window/report grid; the catalog reiterates that plain selectors use `choices`/`stepper`. | complete |

The clean audit receipts include
`catch-system-stretch-20260718`,
`catch-system-stretch-registry-closeout-20260718`, and
`catch-system-stretch-s3-exact-configs-20260718`, followed by the completion
receipts `catch-system-stretch-completion-audit-20260718`,
`catch-system-stretch-s4-select-invariants-20260718`, and
`catch-system-stretch-completion-closeout-20260718`. The owner-gate closeout is
recorded separately as `2026-07-19-catch-system-stretch-owner-gates`. Its final
focused loop has 180 passing Flutter tests across CatchField, CatchChip, the
tabbed-screen shell, and Host operations; focused app and Widgetbook analysis
passes; the full design tool category passes; new-widget inventory reports zero
unresolved items; and the repository readiness gate passes. The earlier final
matrix also has 704 passing Flutter tests across `test/core`,
`test/user_profile`, and `test/hosts`; the full data-contract gate passes and
full analysis has no errors or warnings. The unrelated Explore quality plan is
not part of this implementation and remains untouched.
