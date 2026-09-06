---
doc_id: ui_system_blueprint_conformance
version: 1.8.0
updated: 2026-09-06
owner: app_architecture
status: active
---

# UI System Blueprint And Conformance Audit

## Purpose

This spec answers one owner question: *how should a Flutter product of this
size be structured — code organization, widget abstraction, naming,
state/controller bundling, and enforcement — and where does Catch deviate from
that standard?* It then packages the deviations as a Codex delivery program
whose completion criteria are mechanical, so migrations cannot silently finish
incomplete.

It is a point-in-time plan, not a parallel architecture document. Durable rules
ratified here are folded into `docs/app_architecture.md` (and the widget
catalog maintenance contract) in Phase 0; this file then tracks only delivery.
Where this spec and `docs/app_architecture.md` disagree after Phase 0, the
architecture doc wins.

## Summary Verdict

Catch's UI governance is ahead of typical industry practice in doctrine and
enforcement breadth (90 authored rules, 293 registered checks, an analyzer
plugin with seeded probes, a cross-tool component registry, a provider
topology gate). The deviations are not missing rules — they are four
structural choices that industry systems make and Catch has not yet made:

1. **Boundaries are policed, not compiled.** The design system lives inside the
   app package, so every layering rule needs a scanner. Industry systems make
   the design system a separate package whose `pubspec.yaml` cannot express a
   violation.
2. **The component catalog is documentation, not a test.** 946 Widgetbook use
   cases exist but are never executed as assertions; golden coverage is 5 spec
   files. Industry systems derive visual regression from the catalog corpus so
   the catalog *is* the contract.
3. **Identity is registered in too many places.** A public widget's existence
   is recorded in `docs/widget_catalog.md` prose tables, Widgetbook,
   `design/components/catch.components.json`, and sometimes screen/feature
   contracts. Multi-registry maintenance is the main way "docs fight code."
4. **Migration completion is asserted, not measured.** Exhibits and
   `pattern_adoption.json` classifications are agent-maintained claims. The
   strongest completion proof — the old symbol is deleted and the compiler
   agrees — is used for data migrations but not systematized for UI patterns.

Everything else measured — token pipeline, layer doctrine, controller
taxonomy, async/error architecture, copy ownership — conforms to or exceeds
the reference blueprint and must not be rebuilt.

## Part 1 — Reference Blueprint And Conformance

Each pillar states the industry-standard structure (as practiced by mature
design-system organizations: token pipelines per the DTCG model, layered
component libraries in the style of Material/Polaris/Carbon, catalog-driven
testing in the Storybook/Widgetbook ecosystem, codemod-driven migrations as
practiced in large monorepos), then Catch's mechanism, then a verdict:
`CONFORMS`, `PARTIAL`, `GAP`, or `OVER-BUILT`.

### P1. Physical layering — GAP

**Standard.** The design system is a separate package (often several: tokens,
foundations, components) consumed by app packages. Layering violations
(component library importing state management, backend SDKs, or feature code)
are impossible to compile, not merely flagged. The app's package graph is the
architecture diagram.

**Catch today.** A pub workspace already exists (`apps/consumer`, `apps/host`
over the shared root package), but all UI-system code lives inside the app
package: `lib/core/theme/**` (tokens), `lib/core/widgets/**` (116 files, 193
`Catch*` classes), `lib/core/forms`, `lib/core/responsive`. Boundaries are
held by the analyzer plugin, `check_ui_composition_contracts`, dependency
direction scanners, and convention. Measured leaks prove convention is porous:
5 riverpod-importing files and 31 l10n-coupled files in `core/widgets`, 2
`ConsumerWidget`s in the primitive layer, 7 non-`catch_`-prefixed files.

**Verdict.** GAP. The workspace is already in place; extraction is the missing
step, and it converts a large class of scanner rules into compile errors.

### P2. Token architecture — CONFORMS

**Standard.** DTCG-shaped platform-neutral token source; a three-tier model
(primitive scale → semantic role → component contract); generated per-platform
outputs; raw values only in the token layer.

**Catch today.** `design/tokens/catch.tokens.json` → generated
`catch_design_tokens.g.dart` + generated CSS; handwritten semantic classes
(`CatchTokens`, `CatchSpacing`, `CatchGaps`, `CatchInsets`, `CatchRadius`,
`CatchBorderRole`, …) layered above; tier model documented in
`docs/app_architecture.md`; raw-value drift essentially eliminated by the lint
estate (21 raw `BoxDecoration`s remain outside core, down from ~48 in June).

**Verdict.** CONFORMS. Only defect: the semantic layer is one 3,116-line file
(`lib/core/theme/catch_tokens.dart`) mixing every tier — a split target under
P9, not a redesign.

### P3. Component abstraction ladder — PARTIAL

**Standard.** Components are classified on an explicit ladder, and the
classification is data, not folklore. A canonical form:

| Level | Name | Contents | May depend on |
|---|---|---|---|
| L0 | tokens | scale values, semantic roles | nothing |
| L1 | foundations | theme wiring, typography engine, icons, motion | L0 |
| L2 | primitives | one visual job: text, surface, icon, tap target, gap | L0–L1 |
| L3 | components | reusable assemblies with slots: button, field, section, tile, banner, sheet, empty/error state | L0–L2 |
| L4 | patterns | page-scale skeletons: scaffolds, section pages, tab shells, async-state adapters, form-row orchestration | L0–L3 |
| L5 | feature UI | domain-aware compositions, private allowed | L0–L4 + own feature |
| L6 | screens | route wiring, providers, controllers, navigation | everything below |

Placement is decided by two questions: *does it name a domain concept?* (yes →
L5/L6) and *does it read state management?* (yes → L6 or a designated adapter).
Promotion L5→L3 requires a second unrelated consumer plus catalog registration.

**Catch today.** The ladder exists in prose (widget ownership, promotion
rules, the composition migration spec's Layer 0–N model) and in practice
(tokens → `Catch*` primitives → sections/fields → screens), but: (a) the level
of a given widget is recorded nowhere machine-readable; (b) `core/widgets` is
a flat 116-file namespace where `CatchLoadingIndicator` sits beside `CatchOrganizerPoster`
and `CatchFormStepFlow`; (c) the riverpod-consuming adapters
(`CatchAsyncValueView`, the mutation error family, `CatchNotice`) sit in the
same folder as pure primitives, which is exactly why P1's boundary cannot be
compiled today.

**Verdict.** PARTIAL. Adopt the L0–L6 ladder as the classification vocabulary,
record each shared component's level in the component registry, and let the P1
package split make L0–L4 vs L5–L6 physical.

### P4. Naming grammar — PARTIAL

**Standard.** A closed, written grammar such that two people building the same
thing produce the same name — which is what makes duplicates collide instead
of accumulating. Typical shape: reserved library prefix; a bounded role-noun
lexicon (Button, Field, Section, Tile, Row, Sheet, Banner, Badge, State,
Scaffold…); variants as enums named `<Component><Axis>`; slots from a fixed
vocabulary (`leading`, `trailing`, `title`, `subtitle`, `body`, `footer`,
`actions`, `onX`, `xBuilder`); file suffixes from a fixed vocabulary
(`_screen`, `_controller`, `_view_model`, `_state`, `_repository`,
`_service`, `_providers`, plus role-noun widget suffixes).

**Catch today.** Strong fragments: `Catch` prefix convention, `_state.dart`
naming contract (provider-free by convention, scanner-enforced),
`design:lexicon:check` validating cross-surface component identity for
registered components, `check_widget_classification`, and the new-widget
inventory gate. Missing: the grammar is not written as a closed vocabulary, is
not enforced for unregistered widgets (1,027 public widget classes vs 71
registered component ids), and 7 core files escape the prefix
(`block_user_dialog`, `confirm_danger_dialog`, `event_activity_visuals`,
`event_ticket_surface`, `event_visual_atoms`, `ordered_photo_picker`,
`mutation_error_util`).

**Verdict.** PARTIAL. The collision-forcing goal is currently achieved by the
AST-fingerprint consolidation pipeline (after the fact) rather than by naming
(before the fact). Both are needed; the grammar is cheap to add.

### P5. State and controller bundling — CONFORMS

**Standard.** UI is a function of typed state; state management is confined to
a route-edge container layer; components receive plain data and callbacks;
one-shot actions, flows, async state, and read-only composition have distinct
controller shapes; in-flight requests have explicit snapshot policies.

**Catch today.** This pillar is *ahead* of industry norm:
`ARCH-UI-STATE-001` provider-free presentation states,
`catchAsyncStateFromAsyncValue` with an exhaustive phase model, the
`catch_async_requires_state_surface` diagnostic (Host folders), the
action/flow/async/view-model controller taxonomy, typed mutation key grain,
and `ARCH-PENDING-SNAPSHOT-001` snapshot-integrity policies with named
adopters and tests.

**Verdict.** CONFORMS. The only work is adoption symmetry: the async-surface
diagnostic binds only `lib/hosts/`; consumer presentation still may branch on
raw `AsyncValue` flags. Extend, don't redesign. Do not add new controller
patterns in this program.

### P6. Catalog as executable contract — GAP

**Standard.** The component catalog (Storybook/Widgetbook) is the single
place a component's states are declared, and those declarations are executed:
every catalog case renders in CI, and designated cases produce golden images
diffed on every change (theme × brightness, and text-scale for text-bearing
components). Catalog coverage is asserted over the whole corpus, not just the
diff.

**Catch today.** Widgetbook is real (946 registered use cases, compiled in
CI), and a golden harness exists (`matchCatchGolden`, bundled fonts,
deterministic comparator with 0.30% tolerance, a dedicated
visual-integration CI lane). But the two are not connected: only 5 golden spec
files exist; use cases are compile-checked, never rendered as assertions; and
the coverage gate (`check_new_widget_inventory.mjs`) is diff-based against
`HEAD^`, so anything that ever slips through is invisible forever.

The harness around the catalog is itself large: ≈46,100 handwritten lines
across 28 files with 309 locally defined scaffold classes (device/sheet
frames, provider scopes, catalog grids — every file mounts production
widgets, so there is no shadow UI). Harness volume is a hidden maintenance
tax and a proxy measure of how much of the tree still needs provider
scaffolding to mount in isolation.

**Verdict.** GAP — the highest-leverage one. "UI drift that keeps getting out
of hand" is precisely what whole-corpus rendered goldens catch and nothing
else in the estate does.

### P7. Enforcement design — OVER-BUILT (selectively)

**Standard.** Few, high-leverage rules; each rule ships with its probe (a
fixture proving it fires) and, where mechanical, an autofix; rule count is
kept low by pushing invariants into structure (packages, types) instead of
checks.

**Catch today.** The probe discipline is exemplary (seeded lint corpus,
bidirectional enforcement-coverage gate, enforcement-integrity meta-gate) —
better than most industry teams. But the estate is large (293 checks, 90
rules) partly *because* P1 is unsolved: import-boundary, provider-seam, and
layer-placement rules exist as scanners only because the compiler was never
given the chance to own them. The scanner estate is itself a codebase with
maintenance cost and its own bug surface (per the 2026-08 tooling audit).

**Verdict.** OVER-BUILT in the boundary category, CONFORMS elsewhere. After
P1 lands, retire every check the package graph now owns. Rule count should go
*down* as a result of this program — that is a success metric, not a loss.

### P8. Migration mechanics — GAP

**Standard.** Migrations are codemod-first (`dart fix` data or scripts) and
completion is compiler- or inventory-defined: the old symbol is deleted in the
closing slice, so any missed call site is a build failure, and a deterministic
scanner's zero-count — not an agent's claim — is the definition of done.
Deprecation is a within-migration tool, never an end state.

**Catch today.** The pieces exist separately — exhibits, adopter
classification, decrease-only baselines, the legacy-mirror cutover shape for
data, and the pre-launch clean-schema mandate (no backwards compatibility
anywhere) — but UI/architecture migrations still end with agent-asserted
tracker states, transitional aliases that outlive their slice (`lib/clubs/`),
and baselines with no expiry pressure. This is the root cause of "the agent
does an incomplete job": completion is defined by diligence, not by a
machine.

**Verdict.** GAP. Codified as Migration Protocol v2 (Part 3, D7).

### P9. Size and complexity budgets — GAP

**Standard.** File-size and widget-size budgets, ratcheted: new code obeys the
ceiling, legacy offenders live in a decrease-only baseline.

**Catch today.** Test specs have exactly this (1,200-line ceiling +
decrease-only baseline). Handwritten `lib/` has no budget, and it shows:
`host_crm_repository.dart` 3,624 lines, `catch_tokens.dart` 3,116,
`host_form_builder_screen.dart` 2,927, `host_operational_roster_panel.dart`
2,353, plus four Event Success presentation files between 1,665 and 2,076 —
12 handwritten files sit at or above 1,600 lines.

**Verdict.** GAP, cheap to close: mirror the existing test-size ratchet.

### P10. Doctrine ergonomics — GAP

**Standard.** A short, ranked constitution (one or two pages) answers 90% of
placement/naming/state questions; the long-form spec is reference material;
per-rule detail is generated from the rule registry. Agents and new engineers
load the constitution, not the whole corpus.

**Catch today.** `docs/app_architecture.md` is 4,236 lines (at the
2026-09-04 base) and excellent, but
there is no compact decision layer above it. Every agent session re-derives
"where does this widget go / what is it called / what proves I'm done" from
long prose across several documents. Incomplete migrations are partly a
context problem, not only a discipline problem.

**Verdict.** GAP. Add a one-page decision layer (ladder table + placement
decision tree + naming grammar + protocol checklist) at the top of
`docs/app_architecture.md`, and keep it under 120 lines forever.

### Measured snapshot (2026-09-04)

Re-verify these before executing any phase; date-stamped audits are snapshots.

| Metric | Value | Trend vs 2026-06 |
|---|---:|---|
| Handwritten `lib/**` Dart files / lines | 928 / ~222k (excl. generated l10n) | — |
| Public widget classes in `lib/**` | 1,027 | — |
| Private widget classes | 149 | ↓ from 489 |
| `Widget _buildX()` helper methods | 36 | ↓ from 39 |
| Raw `BoxDecoration` outside `core` | 21 | ↓ from ~48 |
| `core/widgets` files / `Catch*` classes | 116 / 193 | — |
| riverpod-importing files in `core/widgets` | 5 | boundary leak |
| l10n-importing files in `core/widgets` | 31 | boundary leak |
| Widgetbook use cases | 946 | growing |
| Golden spec files / images | 5 / 18 | flat, near-zero |
| Widgetbook handwritten harness lines / files | ~46,100 / 28 | unbudgeted |
| Widgetbook local scaffold classes (frames/scopes) | 309 | no shared harness |
| Registered checks / authored rules | 293 / 90 | growing |
| Handwritten files ≥ 1,600 lines | 12 | unbudgeted |

## Part 2 — Root Causes Of The Two Named Failure Modes

### Why migrations finish incomplete

1. **Completion is a claim.** `pattern_adoption.json` and worklog states are
   written by the same agent doing the migration. Nothing forces the claim
   through a machine except for the few roles covered by
   `check_adopted_architecture_boundaries.mjs`.
2. **The old path survives.** Transitional aliases and compatibility shims are
   left standing "for later," so the compiler never gets to enumerate missed
   call sites. Under the pre-launch clean-schema mandate this caution buys
   nothing.
3. **Doctrine exceeds context.** The rules an agent must satisfy live across
   ~4k lines plus registries; agents satisfy the subset they loaded.
4. **Inventories are ad hoc.** Some migrations start from a grep the agent
   wrote that day rather than a checked-in deterministic scanner, so "all call
   sites" was never a defined set.

### Why source, lints, and tests fight

1. **Multi-registry identity.** Adding one public widget legitimately requires
   touching Widgetbook, `docs/widget_catalog.md` prose tables, sometimes
   `catch.components.json`, and tests. Each is separately gated, so every gate
   feels like friction and drift between them is structural.
2. **Rules arrive after code.** A rule written against an existing violation
   pile forces a baseline/ratchet, which then persists indefinitely (the
   carve-out audit already documented this failure shape for scanners).
3. **Checks duplicate the compiler.** Boundary scanners re-verify things a
   package graph would make unrepresentable, so the same intent is encoded
   twice and can disagree.
4. **Catalog cases assert nothing.** Widgetbook coverage is required but not
   executed, so it reads as ceremony rather than as the component's test — the
   moment a check feels like ceremony, agents and humans route around it.

## Part 3 — Target Decisions

Each decision is final once the owner approves this spec; alternatives are
recorded to prevent re-litigation. **Status: D1–D8 ratified by the owner on
2026-09-04, including the D3 catalog-charter amendment below.**

### D1. Extract `packages/catch_tokens` and `packages/catch_ui`

Workspace gains two members (root `pubspec.yaml` `workspace:` list):

```text
packages/catch_tokens/   # generated primitive tokens + semantic token classes
                         # deps: flutter only
packages/catch_ui/       # foundations, primitives, components, patterns
                         # deps: flutter + catch_tokens (+ phosphor_flutter)
                         # NO riverpod, NO firebase, NO app package, NO feature types
```

Internal layout of `catch_ui` encodes the P3 ladder:

```text
packages/catch_ui/lib/
  catch_ui.dart            # the reviewed barrel (moves from lib/catch_ui.dart)
  src/foundations/         # theme wiring, text styles, icons, motion
  src/primitives/          # L2
  src/components/          # L3 (fields, sections, tiles, banners, sheets, states)
  src/patterns/            # L4 (scaffolds, section pages, tab scroll views,
                           #     form-row orchestration, skeletons)
```

Riverpod-consuming adapters stay in the app package under
`lib/core/riverpod_ui/` (moved from `core/widgets`): `CatchAsyncValueView`,
`CatchAsyncValueSliver`, `CatchMutationErrorBanner`,
`CatchMutationErrorListener(s)`, `mutation_error_util`, `CatchNotice`'s
provider factory. They are thin translations onto `catch_ui` surfaces
(`CatchAsyncState`, `CatchErrorState`), which is what they already are.

Domain-flavored core widgets that name product concepts
(`event_ticket_surface`, `event_activity_visuals`, `event_visual_atoms`,
`CatchOrganizerPoster`, `CatchPersonPolaroid`, `block_user_dialog`,
`confirm_danger_dialog`, `ordered_photo_picker`) are classified during
extraction: entity-material primitives whose API is expressible in
presentation-neutral types move to `catch_ui/src/components`; anything
importing feature domain types stays app-side in `lib/core/widgets` (which
shrinks to the app-coupled remainder) or moves to its owning feature.

*Rejected alternative:* keeping folder-only boundaries and adding more
scanners — that is the current state and the cause of P1/P7 findings.
*Rejected:* extracting a widgetbook/golden package too — the existing
top-level `widgetbook/` app simply repoints its dependency at `catch_ui`.

### D2. `catch_ui` copy policy

`catch_ui` must not import the app localization catalog. Two sanctioned forms:

1. Callers pass already-localized strings (the default; most components
   already work this way).
2. Widget-owned fixed concepts (retry labels, offline notice copy,
   accessibility labels) use a package-local ARB with `gen_l10n` inside
   `catch_ui`, keeping the audience/ownership metadata discipline. The mobile
   copy ownership gate extends its scan roots to the package.

The 31 currently l10n-coupled `core/widgets` files are dispositioned
one-by-one between these two forms during Phase 3; no third form (English
literals in the package) is permitted — the copy scanners keep enforcing
that.

### D3. Goldens are derived from the Widgetbook corpus, and coverage is whole-corpus

- The Widgetbook use case is the single declaration of a component's states.
  A golden runner enumerates designated use cases and renders each at
  light/dark; text-bearing L2–L4 components add text scale 2.0. Reuse
  `matchCatchGolden`, the bundled-font loader, and the checked comparator
  tolerance; run in the existing visual-integration CI lane.
- Adopt the maintained Widgetbook test/generator integration for corpus
  enumeration if it satisfies the spike in Phase 1; hand-roll only the thin
  runner if not (build-vs-adopt policy: prefer adoption, record the trial).
- Coverage becomes whole-corpus: a deterministic script diffs the public
  export surface of `catch_ui` (post-extraction; `core/widgets` `Catch*`
  classes pre-extraction) against golden case ids. Missing coverage is a CI
  failure or an explicit waiver row with owner + expiry. The diff-based
  `HEAD^` gate is retained for feature widgets only.
- **The catalog's charter is tiered by ladder level.** The 2026-09-04 harness
  baseline (≈46,100 handwritten lines, 28 files, 309 local scaffold classes)
  is debt to shrink, not a pattern to extend:
  - **L2–L4 (`catch_ui`):** exhaustive — every variant × theme, knob- or
    matrix-driven, golden-asserted; zero provider scaffolding required by
    construction once D1 lands.
  - **L5 bodies:** a bounded state set, always mounting the production widget
    with `lib/design_fixtures` data — this is composition-regression
    coverage, not decoration.
  - **L6 screens under provider scopes:** lowest value, highest harness tax,
    and redundant with the UI capture pipeline. Each existing case either
    migrates to that pipeline or records an explicit keep reason.
  - **Prototypes:** Widgetbook-defined compositions proposing future UI must
    carry an explicit proposal marker in the case name (for example,
    `· proposed`). They are excluded from production golden coverage. Their
    keep/promote/delete disposition stays with the owning feature review;
    the three `EventSuccessModuleConsolidationPrototype` cases belong to the
    Event Success consolidation review.
  A shared frame/scope harness library and knob-driven state matrices replace
  hand-enumerated permutations; hand-built harness volume becomes a tracked
  measure of remaining provider coupling.

### D4. One identity registry; the widget catalog inventory becomes generated

`design/components/catch.components.json` (plus the source tree itself) is the
identity registry. The inventory tables of `docs/widget_catalog.md` are
generated from a source scan (class, file, level, one-line purpose from the
class doc comment) merged with registry metadata. Hand-written content in the
catalog shrinks to the Canonical Usage Decisions section. The new-widget gate
then checks registry + Widgetbook only — one fewer hand-maintained surface,
which is the single biggest "docs fight code" tax removed.

### D5. Naming grammar v1 is binding

Ratify the grammar in the Appendix, record each shared component's ladder
level and role noun in the registry, extend `design:lexicon:check` +
`check_widget_classification` to enforce: `Catch<RoleNoun>` classes only in
`catch_ui` (role nouns from the closed lexicon), `<Feature><RoleNoun>` for
public feature widgets, file suffix vocabulary, variant enums as
`<Component><Axis>`. The 7 unprefixed core files are renamed or re-homed
during Phase 3 extraction (compiler-verified rename).

### D6. Handwritten source gets the test-size ratchet treatment

New or split handwritten Dart files in `lib/**`, `packages/**`, and
`widgetbook/lib/**` stay at or below 800 lines; existing offenders enter a
decrease-only baseline
(`tool/architecture/flutter_source_size_baseline.json`) mirroring the test
ratchet mechanics exactly. The 12 `lib/**` monoliths and the Widgetbook
use-case monoliths (9,885-line `primitive_contract_use_cases.dart`,
8,586-line `host_operations_use_cases.dart`) get named split plans in
Phase 5 (repository by subdomain, screens by pane/workspace, `catch_tokens`
by tier during Phase 2/3, use-case files by component family onto the
Phase 1 shared harness).

### D7. Migration Protocol v2 (binding for every slice in this program and
after it)

A migration slice is complete only when all five hold:

1. **Inventory first.** A deterministic, checked-in scanner (or `git grep`
   command recorded in the slice) defines the call-site set before work
   starts; its zero-count is part of the DoD.
2. **The old thing is deleted in the same slice.** Old symbol, file, alias,
   or export removed; `flutter analyze` (workspace) green is the completion
   proof. Deprecation may exist only *inside* a slice to stage a `dart fix`
   sweep, never across slices. (Pre-launch mandate: no compatibility layers.)
3. **Ratchets move in the same PR.** Any affected decrease-only baseline is
   lowered in the migration PR, not a follow-up.
4. **New rules ship with probes.** Any lint/check added by the slice lands
   with a seeded fixture proving it fires (existing gold standard), at
   `info` first only if a violation pile exists, promoted within the same
   phase.
5. **Catalog moves with code.** Widgetbook cases, goldens, and registry
   entries for touched shared components update in the same PR.

`pattern_adoption.json` remains for pattern bookkeeping, but an `aligned`
claim must name its machine check or carry an explicit `manual-review` line
with reviewer and date. Every `*_baseline.json` in the repo gains an owner and
target-zero phase reference; a baseline without one is drift
(enforcement-integrity gate extension).

### D8. The check estate shrinks after extraction

After Phase 3, every boundary invariant now expressed by package graphs
(riverpod/firebase/feature imports in the design system, token-definition
placement) has its scanner/lint retired via the existing enforcement-integrity
workflow (rule, manifest, owner-doc anchor, and probe removed together).
Target: net negative check count for this program. New checks added: golden
coverage, source-size ratchet, naming grammar, catalog generation drift —
four in, more than four out.

## Part 4 — Delivery Program

Codex executes all phases. Claude/owner review gates sit between phases.
Every phase obeys Migration Protocol v2 and the repo starting loop
(worktree via `worktree_guard`, derive gates via
`node tool/harness/verify_local.mjs --base origin/main --list`, commit
incrementally). No phase may begin before the previous phase's gate is
explicitly closed by the owner.

### Phase 0 — Ratify and fold in (docs only)

Executed in two slices because `docs/app_architecture.md` and
`docs/widget_catalog.md` were under an active worktree-guard claim
(`events-platform-integration-20260904`) when the program started.

**Phase 0a (landed with this spec):** decisions D1–D8 ratified by the owner
on 2026-09-04 (including the D3 catalog-charter amendment); spec registered
in the docs index; execution-ownership note added to
`docs/design_parity/composition_migration_spec.md`.

**Phase 0b (executed 2026-09-04, same day the claim closed):** the Quick
Decision Layer and Naming Grammar sections now live in
`docs/app_architecture.md` (v1.25.0), the Protocol v2 completion bullet in its
Definition Of Done, and the generated-tables note in
`docs/widget_catalog.md` (v3.11.0). The staged Appendix B was applied and
removed (moved, not copied).

Phase 0 is complete. Phase 1 is unblocked in full.

### Phase 1 — Catalog becomes a test (goldens before any moves)

This lands **before** extraction so the corpus is a safety net under Phases
2–3.

Scope:

1. Spike the Widgetbook corpus→golden integration (adopt-first per D3);
   record the adopt/build decision with evidence in the PR.
2. Golden runner over designated `core/widgets` use cases: light/dark for all;
   text-scale 2.0 for text-bearing components. Deterministic fonts and
   comparator reused from `test/goldens`.
3. Whole-corpus coverage gate `design:golden-coverage` (public `Catch*`
   classes in `core/widgets` vs golden ids; waiver rows carry owner + expiry),
   registered in the tool manifest and the visual-integration lane.
4. Seed baseline images; wire failed-image artifact retention (exists).
5. Use-case triage: a deterministic classifier assigns every registered use
   case to `component-mount`, `body-mount`, `screen-scope`, or `prototype`.
   A `prototype` is a Widgetbook-defined composition proposing future UI,
   requires an explicit proposal marker in its case name (the `· proposed`
   suffix qualifies), and is excluded from the golden-coverage requirement.
   Prototype keep/promote/delete decisions belong to the owning feature
   review; the three Event Success proposals stay with that consolidation
   review and are not edited or deleted by this spike. Generated output stays
   on demand (no tracked ledger); the authored disposition of `screen-scope`
   cases (migrate to the UI capture pipeline vs a named keep reason) is a small
   reviewed source file in Phase 1 proper.
6. Shared harness library: one frame/scope utility set replacing the repeated
   `_DeviceFrame`/`_SheetFrame`/provider-scope shapes, adopted by the
   reference golden slice; knob/matrix-driven state enumeration for L2–L4
   cases so permutations stop being hand-written.
7. No production `lib/**` changes in this phase beyond test/catalog code.

DoD (mechanical): coverage gate green with waivers ≤ 20; golden suite green
twice consecutively in CI (flake check); a deliberately broken spacing token
in a scratch branch produces a visible golden diff (known-bad proof); the
triage classifier covers every registered use case with zero unclassified
across `component-mount | body-mount | screen-scope | prototype`, every
prototype has an explicit proposal marker, and every `screen-scope` case
carries a disposition. Importing the production package is only a proxy for
production mounting: the three Event Success prototypes are identified
exceptions, despite importing production primitives.

**Execution (2026-09-05):** Phase 1 is implemented. The adopted
`widgetbook_golden_test_core` generator enumerates all 972 registered use
cases inside `flutter_test`; the Catch adapter retains the existing bundled
fonts, theme setup, and `matchCatchGolden` comparator. The app-golden default
remains 0.30%; the text-heavy Widgetbook corpus uses a separately checked
0.60% allowance after reviewed macOS 26 arm64 CI diffs measured at most
0.5188% against macOS 27 authoring baselines and were confined to
anti-aliased text/icon edges. The designated `core/widgets` corpus contains
249 golden ids: every case renders
at light and dark, and 217 text-bearing L2–L4 cases also render at text scale
2.0. The checked baseline contains 944 images. Two consecutive local runs
passed all 469 tests in 1:07 each with no rendering drift. The CI lane runs
the same corpus twice sequentially and retains failure artifacts.

The whole-corpus coverage gate measures 259 public pre-extraction `Catch*`
classes: 241 are covered by 249 golden ids and 19 carry owner/expiry waivers
(limit 20). The four-class triage measures 274 `component-mount`, 335
`body-mount`, 360 `screen-scope`, and 3 `prototype` cases, with zero
unclassified. All 360 screen-scope cases have authored dispositions (65
`migrate-to-ui-capture`, 295 `keep-widgetbook`). The three prototypes retain
the `· proposed` marker and remain owned by the Event Success consolidation
review. A shared catalog/device/sheet frame API plus provider and case scopes
now owns the repeated harness shapes; the reference cases and golden runner
adopt it without a bulk catalog migration.

The known-bad proof remains isolated on scratch commit `0171d20e0`: changing
`CatchSpacing.s4` from 16 to 32 fails the reference menu-row goldens by
22.8727% (light) and 22.8691% (dark), above both checked thresholds. The scratch
commit is not part of Phase 1 history. No production `lib/**` file changed.
The owner closed the Phase 1 review gate by merging PR #335 and authorizing
Phase 2 continuation.

### Phase 2 — `packages/catch_tokens`

Scope: create the package; retarget `tool/design_tokens.dart` generator
output; move generated primitive tokens plus the semantic token classes,
splitting the token monolith by tier during the move (D6);
rewrite imports
mechanically across the workspace; delete the migrated originals
(`lib/core/theme/catch_tokens.dart`, `catch_platform_tokens.dart`, and
`generated/catch_design_tokens.g.dart`); keep the lint plugin's token exemption
pointed at the new package. Theme wiring, typography, icon assets, gap widgets,
and app-coupled activity palettes remain app-side until Phase 3.

DoD: old files gone; `flutter analyze` green across workspace members and
widgetbook; `dart run tool/design_tokens.dart --check` green; goldens
unchanged (Phase 1 proof of no visual drift); lint probe corpus green.

Implementation: `packages/catch_tokens` is a Flutter-only production dependency
in the Dart workspace and exports generated scales plus handwritten primitive,
semantic, and component token units. Its 20 handwritten library files stay
within D6 (largest: 796 lines). Welcome reel and form-workspace geometry have
separate token owners; their expressions and the remaining token values are
preserved. The three migrated originals are deleted, all active consumers use
the package, generator/discovery paths follow it, and the affected test-size
ratchet is lowered. The package dependency check rejects non-Flutter packages;
standard Flutter lints reject undeclared app imports. The workspace analyzer
explicitly targets the package's `lib` source after a seeded probe demonstrated
that directory-wide Flutter analysis could skip it.

The owner closed the Phase 2 gate by approving PR #365 for merge and
authorizing continuation. It merged as `8ba30b124288c4f36a7f39850d07a50bbc672fd6`.

### Phase 3 — `packages/catch_ui`

Sub-slices, each independently gated by compiler + goldens:

- 3a foundations (text styles, icons, motion, theme wiring);
- 3b primitives (L2);
- 3c components (L3: fields, sections, tiles, states, sheets) with the D2
  l10n disposition of the 31 coupled files and D5 renames of the 7 unprefixed
  files;
- 3d patterns (L4: scaffolds, section pages, tab scroll views, form-row
  orchestration) and the `lib/core/riverpod_ui/` adapter move;
- 3e entity-material classification (poster/polaroid/ticket family) per D1;
- 3f `widgetbook/` repointed to depend on `catch_ui` (+ app package only where
  feature use cases require it); `lib/catch_ui.dart` barrel becomes a
  re-export shim for exactly one slice, then is deleted.

DoD per slice: moved files deleted at origin; workspace analyze green;
goldens unchanged or intentionally re-baselined with review; `catch_ui`
pubspec contains no riverpod/firebase/app dependency (checked by a one-line
manifest assertion, replacing the scanners it obsoletes).

Phase 3a moves the font registry, semantic text styles, icon facade, motion
helpers, and bundled font/license assets into `catch_ui/lib/src/foundations`.
`CatchTheme` owns feature-neutral Material wiring; the app retains `AppTheme`
as the activity-palette adapter. Branded styles use package-qualified font
families, and the existing golden loader resolves the same bundled bytes.
The package boundary permits only Flutter, `catch_tokens`, and Phosphor;
workspace analysis explicitly visits its library and test sources.

Phase 3b moves the provider-free surface, control shell, row-press surface,
text/icon atoms, gap values, image loading/grade/scrim, dividers, indicators,
and focused sizing/reveal protocols into `catch_ui/src/primitives`. The image
fallback has its own file. Motion render helpers become cataloged viewport
widgets with the same transitions; each has a single owning file. Each original
app file is deleted. Golden discovery
counts both remaining app classes and extracted primitives, preserving every
pre-move class and case instead of losing coverage at the package boundary.
Components, patterns/adapters, entity materials, and final public-barrel cleanup
remain the later Phase 3 sub-slices.

Phase 3c begins with provider-free badges, icon actions, status displays, charts,
record rows, section headers, and timestamp layout. These component bodies and
caller-owned copy are preserved at their package home; original files are
deleted and their exact corpus coverage follows the move. Buttons and index
rows follow, with button label/loading anatomy in individual files. Share-card
footers receive their existing localized brand label from app callers;
step progress receives a caller-owned counter formatter. The latter has only
catalog/test consumers, so its unused app-catalog entry is removed. The copy
ownership gate scans the package as well as the app. Optional field labels and
framework-error displays also receive resolved copy through the app presentation
adapter, including screen-reader labels and the debug-details disclosure. Their
public badge/disclosure anatomy has individual files. Provider-free bottom-sheet
chrome, day headers, metadata rows, and metric strips retain their public APIs
and layout behavior in individual package files. The remaining l10n-coupled
field/section/sheet families retain their later extraction work.

### Phase 4 — One registry, binding grammar

Scope: catalog inventory generator + drift check (D4); registry gains
`level` and `roleNoun` fields with schema validation; lexicon/classification
checks extended to the grammar (D5); `design:widgets:*` gates simplified to
registry+Widgetbook; one-time grammar conformance sweep over `catch_ui`
public API (renames are compiler-verified; staged `dart fix` data allowed
within the slice).

DoD: `docs/widget_catalog.md` inventory sections carry a generated-file
header and the drift check fails on hand edits; grammar check green with a
seeded known-bad probe; new-widget gate no longer requires markdown table
edits.

### Phase 5 — Budgets, splits, and estate shrink

Scope: source-size ratchet (D6) registered and CI-gated; split plans executed
for the 12 files at or above 1,600 lines (each split is a Protocol v2 slice;
`host_crm_repository` splits by CRM subdomain, Event Success presentation by
part-file elimination into real components, form-builder screen by pane,
Widgetbook use-case monoliths by component family onto the shared harness);
scanner/lint retirement per D8 through enforcement-integrity; baseline expiry
annotations (D7) added and validated.

DoD: ratchet green; monolith baseline reduced to ≤ 4 `lib/**` entries and
zero `widgetbook/lib/**` entries; net check
count strictly lower than the Phase 0 snapshot (record both numbers in the
PR); every baseline names owner + target phase.

### Phase 6 — Continuous conformance (folds into existing lanes)

Not a Codex batch — assignments into existing owners: consumer-side parity
for `catch_async_requires_state_surface`; remaining 149 private widgets, 36
helper methods, 21 raw decorations continue through the widget-consolidation
worklog's K/R/D lanes (that spec keeps ownership; this program does not
duplicate it); golden waivers burn to zero.

### Work packet template (every Codex slice)

```text
Packet: <phase>.<n> <title>
Inventory command: <exact command whose zero-output defines done>
Deletes: <old symbols/files that must not exist afterward>
Adds: <code + lint/check + probe + widgetbook/golden + registry rows>
Ratchets touched: <baseline files lowered in this PR>
Verification: <exact check ids / commands, derived via verify_local --list>
Escalation: stop and report if the inventory shrinks by editing the scanner,
if a delete requires a compatibility shim, or if a rule needs a carve-out —
those are owner decisions, not implementation details.
```

## Part 5 — Interactions With In-Flight Work

| In-flight | Relationship |
|---|---|
| `widget_consolidation_pipeline_spec.md` | Unchanged owner of dedupe (K/R/D). Phase 4's grammar reduces its future intake. |
| `catch_field_section_system_spec.md` | Field/section internals move in 3c; its gated phases rebase onto `catch_ui` paths, contracts unchanged. |
| `catch_ui_lint_rules_plan.md` | Phase 1.5 scanner retirements merge into D8's estate shrink; probe harness gains the package roots. |
| `ui_capture_pipeline_plan.md` | Shares the golden harness; capture consumers unaffected. |
| `ds_resync_audit_2026-06.md` | Porting work continues; new ports land directly in `catch_ui` once 3b is closed. |
| `composition_migration_spec.md` | This program is the executor of its layer-model "needed work"; that spec stays the cross-tool contract owner. |
| Host adaptive workspace slices | Unaffected; they consume patterns (L4) wherever those live. |

## Appendix A — Naming Grammar v1 (ratified 2026-09-04)

After Phase 0b the durable owner of this grammar is
`docs/app_architecture.md`; this appendix remains the ratification record and
defers to that section on any conflict.

- **Prefixes.** `Catch` is reserved for `catch_tokens`/`catch_ui` symbols (and
  the app-side riverpod adapters that wrap them). Public feature widgets are
  `<Feature><RoleNoun>`; private widgets `_<Anything>` are legal only in L5.
- **Role nouns (closed; extend only via registry review):** Button, IconAction,
  Field, FieldLanes, Section, SectionList, Tile, Row, RowList, Chip, Badge,
  Banner, Sheet, Dialog, Notice, EmptyState, ErrorState, Skeleton, Indicator,
  TopBar, Header, HeaderTitle, Scaffold, PageBody, ScrollView, TabBar,
  TabScaffold, Poster, Polaroid, Ticket, Gap, Inset, Divider, Avatar, Photo,
  Cover, Stepper, StepFlow, Accordion, Drawer, Overlay, Viewport.
- **Files.** Snake case of the primary public class; suffix vocabulary:
  `_screen`, `_controller`, `_view_model`, `_state`, `_repository`,
  `_service`, `_providers`, or a role-noun suffix for widgets. One primary
  public widget per file in `catch_ui` (its parts private in-file).
- **Variants.** Axes are enums named `<Component><Axis>` with axis vocabulary
  `Variant`, `Size`, `Tone`, `Emphasis`, `Status`, `Placement`, `Mode`. At
  most two booleans per public component constructor; a third forces an enum.
- **Slots.** `leading`, `trailing`, `title`, `subtitle`, `kicker`, `meta`,
  `body`, `footer`, `actions`, `media`, `mediaOverlay`, `child`, `children`;
  builders end in `Builder`; callbacks start with `on`.
- **State objects.** `<Surface>State` (provider-free), `<Surface>ViewModel`
  (provider-owned composition), `<Surface>Controller` (mutations/flows) — as
  already contracted.
