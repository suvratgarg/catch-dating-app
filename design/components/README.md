---
doc_id: component_contract_registry
version: 1.4.0
updated: 2026-07-19
owner: ui_elevation_initiative
status: active
---

# Component Contract Registry

`catch.components.json` is the cross-tool contract layer for Catch UI
primitives. Flutter remains the implementation source of truth; this registry
names the public component contract that Figma, Claude Design, future Code
Connect templates, docs, and validators should agree on.

The registry deliberately describes component APIs, states, slots, token
dependencies, handoff names, and concept identity. A top-level contract is not
automatically an independent concept: `conceptRole` distinguishes a primary
concept from a member, composition, or screen while preserving useful public
handoff contracts. It does not attempt to generate Dart widget
implementations from JSX, CSS, or Figma node geometry.

It is also the exhaustive UI-enforcement source. Every component must declare
either `enforcement` or an expiring `waiver`. Steering entries generate the
analyzer plugin constructor tables and violation probes; all other plugin/API/
checker codes still map back to an owning component through `code`/`codes`.

## Files

| File | Purpose |
|---|---|
| `catch.components.json` | Authoritative component contract registry. |
| `catch.components.schema.json` | JSON Schema for the registry shape. |
| `../../tool/design/generated/enforcement_expectations.json` | Generated code ownership and anti-vacuity expectations for repository gates. |

## Workflow

1. Add or change the Flutter primitive in `lib/core/widgets`.
2. Update the matching contract entry here, including props, states, slots, and
   DTCG token references.
3. Add or revise the enforcement decision; new waivers need a reason, owner,
   and review expiry.
4. Run `node tool/design/build_lint_enforcement_tables.mjs`, then
   `node tool/design/check_component_enforcement_coverage.mjs`.
5. Run `node tool/design/check_component_contracts.mjs`.
6. Regenerate the design context pack with
   `node tool/design/build_context_pack.mjs` when the registry should be shared
   with Claude Design or another design tool.
7. Regenerate `design/sync/catch.design-sync.json` so mapping state and contract
   digests stay current.

Use `Catch<ControlledNoun>` for new concepts. Prefer named constructors for
variants, concept-qualified names for public members, and explicit adapter or
recipe qualifiers when a standalone class solves a real API problem without
creating another concept. Feature compositions normally keep feature names and
do not count as concepts.

Concept boundaries follow semantic responsibility, not a shared circumstance
or visual shape. If one contract contains independently configurable behavior
with different usage rules, split its concept identity even when stable Dart
class names do not need to change. The loading family is the reference case:
`catch.skeleton`, `catch.loading_indicator`, and `catch.async_value` are three
concepts, while `catch.startup_loading_screen` is a composition over the
indicator. Conversely, feature adapters that only retain semantics, pending
state, or stable test keys should configure an existing renderer rather than
claim another core concept.

Figma mappings start as `unmapped`. The registry's `componentName` is the stable
join key. A library-publish snapshot supplies the file key and node id, and the
sync manifest generates the node URL; live mappings do not require hand-edited
URLs. The old `status` and `componentUrl` fields remain accepted as declared
fallback metadata and are treated as stale when no captured node proves them.
Code Connect templates should live beside their owning Flutter primitive or in
a dedicated Figma mapping folder, and the registry should point at that
template. The executable sync contract, snapshot importer, and current
live-capability receipt live in `design/sync/README.md`.
