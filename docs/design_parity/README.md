---
doc_id: design_parity_tracker
version: 0.1.18
updated: 2026-07-23
owner: product_design_parity
status: active
---

# Design Parity Tracker

This folder owns the feature-by-feature contract for bringing Catch screens and
widgets closer to the design specification. It connects product states, Flutter
screens, reusable components, UI captures, future previews, and drift-prevention
checks in one durable matrix.

## Source Files

| File | Purpose |
|---|---|
| `claude_widgetbook_inventory.md` | Persistent inventory comparison between the Claude Design export, local Widgetbook, local component contracts, and foundation token/style sources. |
| `comprehensive_todo.md` | Canonical execution checklist for remaining design-parity work across sources of truth, state contracts, Widgetbook, captures, pixel comparison, composition, tokens, features, drift prevention, and pass cadence. |
| `composition_migration_spec.md` | Layered implementation spec for migrating screens into controller-owned state composition, registered sections, registered components, and platform-neutral design tokens/contracts. |
| `event_detail_composition_tracker.md` | First screen-level composition tracker, mapping Event Detail from Claude event primitives to current Flutter sections, states, Widgetbook gaps, and migration tasks. |
| `design/screens/screen_coverage.json` | Exhaustive route-to-screen coverage ledger. Every generated route is contracted, aliased, planned, or excluded from baseline design parity. |
| `design/screens/catch.screens.json` | Machine-readable screen composition registry connecting routes, controller owners, states, captures, sections, and implementation paths. |
| `design/features/*.feature.json` | Structured multi-surface feature orchestration contracts. Each surface binds a Flutter screen, marketing route, or admin route plus native components, action owners, and evidence. |
| `design/features/generated/*.feature_contract.json` | Generated cross-surface state/action/evidence projections. These artifacts are deterministic and must not be edited by hand. |
| `design/features/feature_coverage.json` | Exhaustive cross-surface migration ledger. Every registered Flutter screen, marketing route, and admin route component is contracted, grouped, planned with stable debt, or explicitly excluded. |
| `tool/design/check_design_parity.mjs` | Standard local design parity gate. Runs component contracts, route inventory, capture coverage, screen coverage, screen contracts, Widgetbook refs, and advisory scanners. |
| `tool/design/build_feature_contracts.mjs` | Compiles multi-surface feature sources, enforces exact authority-state coverage and action cardinality, resolves runtime-native evidence, and fails stale generated output. |
| `tool/design/check_feature_coverage.mjs` | Fails missing, duplicate, unknown, falsely contracted, or orphaned feature coverage across the three product runtimes. |
| `tool/design/check_screen_coverage.mjs` | Validates screen coverage against route inventory, capture coverage, and the screen composition registry. |
| `tool/design/check_screen_contracts.mjs` | Validates screen contracts against route inventory, capture catalog entries, component dependencies, Flutter source paths, and Dart symbols. |
| `tool/design/check_widgetbook_contract_refs.mjs` | Validates component contracts and contract preview ids against generated Widgetbook directories. |
| `tool/design/check_screen_contract_hygiene.mjs` | Advisory scanner for raw Material controls and hand-rolled visual values in contracted screen implementation files. Masks comments/string literals, ignores `Colors.transparent`, and prints sample line refs so findings are reviewable before promotion to lints. |
| `tool/design/screen_top_bar_contracts.json` | Exhaustive role classification for every Flutter `Scaffold.appBar`, every consumer/Host tab-root header surface, canonical zero-inset geometry, and reviewed raw media-hero exceptions. New app bars and shell branches are unregistered by default and fail the gate. |
| `tool/design/check_screen_top_bar_contracts.mjs` | Blocking screen-chrome gate. Rejects unregistered/raw/wrong app-bar owners, incomplete tab-root coverage, root headers that bypass `CatchScreenHeaderTitle`/`CatchScreenTopBar`, local padding/height/text-scaling overrides, and a nonzero canonical post-safe-area inset. |
| `tool/design/check_screen_gutters.mjs` | Advisory inventory for `EdgeInsets` constructors across `lib/**/presentation/**/*.dart` and contracted screen implementation files. Classifies likely screen-gutter candidates separately from lower-confidence local spacing so manual UI reviews have broad evidence instead of a narrow lint. |
| `design/reference_screens/manifest.json` | Exported design-reference PNG manifest used for advisory pixel comparison. |
| `tool/design/check_reference_screens.mjs` | Validates reference PNG metadata and can compare exported references against UI capture output. |
| `state_matrix.json` | Machine-readable feature/state matrix for design parity passes. |
| `state_matrix.schema.json` | JSON Schema for the matrix shape. |
| `tool/design/check_design_parity_matrix.mjs` | Validates routes, captures, component ids, screen contracts, source paths, tests, and state entries. |
| `widgetbook/` | Local Widgetbook workspace for reusable component and hard-to-reach state previews. |

## Pass Workflow

1. Choose one feature from `state_matrix.json`.
2. Read the feature's design refs, implementation paths, component ids, capture
   ids, and open gaps.
3. Expand the state list before editing UI. Include loading, populated, empty,
   error, offline, permission, mutation, light/dark, text-scale, and reduced
   motion states when they apply.
4. Add or update fixtures, captures, previews, tests, and component contracts as
   part of the same feature pass.
5. Run the local design parity gate:

   ```bash
   npm run design:parity:check
   ```

6. Run focused analyzer/tests/scanners for the touched feature.
7. Stamp the pass in `docs/audit_registry/passes.jsonl`.

## New Route Workflow

When `lib/routing/go_router.dart` changes, update the route-derived design
ledgers in the same PR:

1. Regenerate the route inventory:

   ```bash
   node tool/ui_capture/check_route_inventory.mjs --update
   ```

2. Add or update the route in `design/screens/screen_coverage.json` with one of
   the explicit decisions: `contracted`, `alias`, `planned`, or `excluded`.
3. Add or update the route in `tool/ui_capture/capture_coverage.json` with one
   of the explicit capture decisions: `captured`, `alias`, `planned`, or
   `excluded`.
4. For a new product screen, add the screen contract in
   `design/screens/catch.screens.json` and a matching screen/state entry in
   `docs/design_parity/state_matrix.json`.
5. Run the aggregate gate:

   ```bash
   npm run design:parity:check
   ```

Flutter CI also runs this gate, so new product routes cannot pass CI without
screen and capture coverage decisions.

The router remains the source for path inventory only. Rich design metadata
belongs in the portable `design/screens` and `docs/design_parity` ledgers so the
same contracts can serve Flutter, Widgetbook, website/social templates, and
future design-tool exports without making Dart routing the design source of
truth.

## State Statuses

- `planned`: Known requirement; no implementation proof yet.
- `implemented`: Code path exists, but capture/preview/test proof is incomplete.
- `captured`: UI capture exists for the state.
- `tested`: Automated widget/unit/integration test covers the state.
- `ready`: State has implementation, useful visual proof, and relevant tests.
- `blocked`: State is blocked by missing fixture/data/tooling/design source.

## Visual Comparison Policy

Pixel comparison should be introduced as an advisory gate first. Store exported
design references under `design/reference_screens/` and compare them against
`tool/ui_capture/run_captures.mjs` output. Mask dynamic regions such as status
bars, maps, timestamps, remote photos, and generated counters before enforcing a
threshold.

Dashboard Home is the first wired baseline. Refresh the comparable Flutter
captures with:

```bash
node tool/ui_capture/run_captures.mjs --ids dashboard_home,dashboard_home_empty_start --device design-phone --output-dir /tmp/catch-dashboard-reference-captures
```

Then run the advisory comparison:

```bash
node tool/design/check_reference_screens.mjs --compare --capture-dir /tmp/catch-dashboard-reference-captures
```

Host references must use a repo-pinned `design/source_packs/` source with a
hash-complete, locally closed dependency manifest and must compare the real
application navigation chrome. App Build Matrix regenerates the four primary
full-shell Host captures and runs a focused `--strict` comparison. Strict mode
fails unknown or missing captures, dimension drift, and threshold regressions.
A real but unfinished feature may declare a stable `parityDebtId` plus a looser
`regressionThresholds` ceiling; that ceiling prevents further drift and does
not change the canonical parity threshold or close the debt.

## Preview Policy

Use previews for hard-to-reach component and screen states. Use route captures
for full-screen composition, navigation chrome, fixture realism, and review
artifacts. A state can be `ready` with either a useful route capture or a useful
preview, but high-traffic P1 routes should eventually have both.

The local Widgetbook workspace lives in `widgetbook/`. Primitive previews should
map to `design/components/catch.components.json` contract states, and screen
previews should use the same fixture fakes as UI captures where possible. Run
`cd widgetbook && dart run build_runner build` after adding annotated use cases.

## Feature Contract Compiler

Feature contracts are orchestration indexes, not replacement sources of truth.
They declare one semantic feature identity with one or more runtime-specific
surface projections. Each surface declares valid state dimensions, cardinality
for explicit action domains, and one mapping for every state in its owning
screen or route contract. It references native component ids, action-owner
symbols, data-contract paths, previews, captures, and tests; the compiler
resolves those authorities into one checked generated artifact.

The compiler is paired with `design/features/feature_coverage.json`. That ledger
defines the complete migration boundary from existing authoritative registries,
so adding a Flutter screen, marketing route, or admin route component without a
feature decision fails the design-parity gate. A `planned` target may intentionally
reuse an existing feature identity across runtimes. `feature.explore` is the
first checked example: it contains both `screen.explore.discovery` and the
marketing `organizer_search` route, while their components, action owners,
states, and evidence remain runtime-specific.

Event Detail, Explore, Host Event Manage, Catches Hub, Catches Event, Matches
List, Member Chat, Self Profile, and Public Profile are the current reference
contracts.
Actions name one of the surface's declared Dart or TypeScript owners, so a
larger feature may compose multiple action domains without pretending one enum
or controller owns everything. Action outcomes are typed as local surface
states, route destinations, or side effects. A read-only surface may declare no
actions or action owners; the format never requires fabricated behavior.

For state-rich surfaces, use the compact state matrix: `stateIds` must list the
authority's exact state inventory, `scenarioDefaults` declares the repeated
dimension/action case once, and `scenarioOverrides` records only meaningful
differences. The compiler expands this into the same generated scenario
projection and rejects missing, unknown, duplicate, or out-of-inventory state
overrides. This keeps source contracts reviewable without allowing a newly
registered state to pass silently.

Required evidence stays strict. A real missing capture, preview, or test may be
admitted only through an explicit evidence exception tied to a stable open debt
id. The compiler rejects missing exceptions and also rejects stale exceptions
after the evidence is added. Compile and verify the contracts with:

```bash
node tool/design/check_feature_coverage.mjs --check
node tool/design/build_feature_contracts.mjs
node tool/design/build_feature_contracts.mjs --check
```

The compiler fails duplicate surfaces or authority bindings, runtime/authority
mismatches, duplicate or missing authority-state mappings, unknown action owner,
action, outcome, route, or dimension values, undeclared Dart/TypeScript symbols,
missing component/data paths, missing capture/preview/test evidence, unused
evidence exceptions, stale output, and orphaned generated artifacts. Natural-language
briefs may inform a contract draft, but only the reviewed JSON source is
executable. Flutter widgets, controllers, business algorithms, security rules,
and migrations remain manually implemented and tested against their owning
contracts.
