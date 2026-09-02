---
doc_id: component_contract_registry
version: 1.6.0
updated: 2026-09-03
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

Every component contract also carries executable cross-surface accessibility
acceptance metadata. The registry requires support for text scale 2.0, a stable
reduced-motion resting state, and both Light and Dark semantic themes. A
component-specific policy may be stricter, but it cannot omit those baselines.

It is also the exhaustive UI-governance source. Every component must declare
exactly one decision: static `enforcement`, executable `verification`, or an
expiring exceptional `waiver`. Steering entries generate the analyzer plugin
constructor tables and violation probes; all other plugin/API/checker codes
still map back to an owning component through `code`/`codes`. `vehicle` names
the implementation of the primary `code`; supplemental `codes` may span
vehicles when one component is protected by complementary gates.

Use `verification.vehicle: widgetbook-contract` when the canonical component
has no distinct static misuse pattern. The coverage checker derives the target
from `dart.symbol` and requires that exact generated Widgetbook component, so
the decision cannot be satisfied by prose. A `waiver` is only for a temporary
gap with a named owner, a specific reason, and a review expiry.

## Files

| File | Purpose |
|---|---|
| `catch.components.json` | Authoritative component contract registry. |
| `catch.components.schema.json` | JSON Schema for the registry shape. |
| `../../tool/design/generated/enforcement_expectations.json` | Generated code ownership and anti-vacuity expectations for repository gates. |

## Workflow

1. Add or change the Flutter primitive in `lib/core/widgets`.
2. Update the matching contract entry here, including props, states, slots, and
   DTCG token references. Confirm its accessibility policy preserves primary
   meaning and actions at text scale 2.0 and does not depend on motion.
3. Add or revise the governance decision. Prefer static enforcement when a
   misuse pattern is mechanically detectable; otherwise use executable
   verification. New waivers need a specific reason, owner, and review expiry.
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
`design.figma.propertyProjection` is the explicit tool-facing API when a usable
Figma component should not mirror every code prop or review state one-to-one.
Its properties must cite the owning code props, while `reviewStates: evidence`
keeps large governed state sets in review galleries instead of multiplying the
public variant matrix. Optional code slots may intentionally project as both a
Boolean visibility control and an instance-swap control.
Code Connect templates should live beside their owning Flutter primitive or in
a dedicated Figma mapping folder, and the registry should point at that
template. The executable sync contract, snapshot importer, and current
live-capability receipt live in `design/sync/README.md`.
