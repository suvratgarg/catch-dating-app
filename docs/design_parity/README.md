---
doc_id: design_parity_tracker
version: 0.1.9
updated: 2026-06-22
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
| `design_parity_todo.md` | Detailed working backlog and historical evidence trail. Prefer `comprehensive_todo.md` for the current execution order. |
| `event_detail_composition_tracker.md` | First screen-level composition tracker, mapping Event Detail from Claude event primitives to current Flutter sections, states, Widgetbook gaps, and migration tasks. |
| `design/screens/screen_coverage.json` | Exhaustive route-to-screen coverage ledger. Every generated route is contracted, aliased, planned, or excluded from baseline design parity. |
| `design/screens/catch.screens.json` | Machine-readable screen composition registry connecting routes, controller owners, states, captures, sections, and implementation paths. |
| `tool/design/check_design_parity.mjs` | Standard local design parity gate. Runs component contracts, route inventory, capture coverage, screen coverage, screen contracts, Widgetbook refs, and advisory scanners. |
| `tool/design/check_screen_coverage.mjs` | Validates screen coverage against route inventory, capture coverage, and the screen composition registry. |
| `tool/design/check_screen_contracts.mjs` | Validates screen contracts against route inventory, capture catalog entries, component dependencies, Flutter source paths, and Dart symbols. |
| `tool/design/check_widgetbook_contract_refs.mjs` | Validates component contracts and contract preview ids against generated Widgetbook directories. |
| `tool/design/check_screen_contract_hygiene.mjs` | Advisory scanner for raw Material controls and hand-rolled visual values in contracted screen implementation files. Masks comments/string literals, ignores `Colors.transparent`, and prints sample line refs so findings are reviewable before promotion to lints. |
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

## Preview Policy

Use previews for hard-to-reach component and screen states. Use route captures
for full-screen composition, navigation chrome, fixture realism, and review
artifacts. A state can be `ready` with either a useful route capture or a useful
preview, but high-traffic P1 routes should eventually have both.

The local Widgetbook workspace lives in `widgetbook/`. Primitive previews should
map to `design/components/catch.components.json` contract states, and screen
previews should use the same fixture fakes as UI captures where possible. Run
`cd widgetbook && dart run build_runner build` after adding annotated use cases.
