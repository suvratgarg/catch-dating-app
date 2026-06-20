---
doc_id: design_parity_tracker
version: 0.1.0
updated: 2026-06-20
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
| `state_matrix.json` | Machine-readable feature/state matrix for design parity passes. |
| `state_matrix.schema.json` | JSON Schema for the matrix shape. |
| `tool/design/check_design_parity_matrix.mjs` | Validates routes, captures, component ids, source paths, tests, and state entries. |

## Pass Workflow

1. Choose one feature from `state_matrix.json`.
2. Read the feature's design refs, implementation paths, component ids, capture
   ids, and open gaps.
3. Expand the state list before editing UI. Include loading, populated, empty,
   error, offline, permission, mutation, light/dark, text-scale, and reduced
   motion states when they apply.
4. Add or update fixtures, captures, previews, tests, and component contracts as
   part of the same feature pass.
5. Run the validator:

   ```bash
   node tool/design/check_design_parity_matrix.mjs --check
   ```

6. Run focused analyzer/tests/scanners for the touched feature.
7. Stamp the pass in `docs/audit_registry/passes.jsonl`.

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

## Preview Policy

Use previews for hard-to-reach component and screen states. Use route captures
for full-screen composition, navigation chrome, fixture realism, and review
artifacts. A state can be `ready` with either a useful route capture or a useful
preview, but high-traffic P1 routes should eventually have both.
